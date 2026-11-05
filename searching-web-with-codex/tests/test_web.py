"""CLI contract tests; all credentials are fixtures and no external network is used."""

import importlib.util
import io
import json
import os
import subprocess
import sys
import threading
import unittest
from contextlib import redirect_stderr, redirect_stdout
from email.message import Message
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from tempfile import TemporaryDirectory
from unittest.mock import patch
from urllib.error import HTTPError, URLError

from scripts import web


class WebCliTests(unittest.TestCase):
    def setUp(self):
        directory = TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.home = Path(directory.name)
        self.auth = self.home / "auth.json"
        self.auth.write_text(
            json.dumps(
                {
                    "auth_mode": "chatgpt",
                    "tokens": {"access_token": "fixture-secret", "account_id": "fixture-account"},
                }
            )
        )
        (self.home / "config.toml").write_text('model = "fixture-model"\n')
        environment = patch.dict(
            os.environ,
            {"CODEX_HOME": directory.name, "CODEX_WEB_MODEL": "fixture-model"},
            clear=True,
        )
        environment.start()
        self.addCleanup(environment.stop)

    def invoke(self, *args):
        stdout, stderr = io.StringIO(), io.StringIO()
        with redirect_stdout(stdout), redirect_stderr(stderr):
            try:
                code = web.main(list(args))
            except SystemExit as error:
                code = error.code
        return code, stdout.getvalue(), stderr.getvalue()

    def test_search_posts_codex_contract_and_preserves_results(self):
        results = [{"type": "text_result", "url": "https://example.com", "future": {"x": [1]}}]
        original = self.auth.read_bytes(), self.auth.stat().st_mtime_ns
        with patch.object(web, "build_opener") as opener:
            opener.return_value.open.return_value = io.BytesIO(
                json.dumps(
                    {
                        "output": "原始文本\nciteturn0search0",
                        "results": results,
                        "encrypted_output": "not-forwarded",
                    }
                ).encode()
            )
            code, stdout, stderr = self.invoke(
                "--session",
                "session-1",
                "--mode",
                "live",
                "search",
                "Python 网络",
                "--recency",
                "7",
                "--domain",
                "docs.python.org",
            )
            self.assertEqual((code, stderr), (0, ""))
            request = opener.return_value.open.call_args.args[0]
            self.assertEqual(request.full_url, web.ENDPOINT)
            self.assertEqual(request.get_method(), "POST")
            self.assertEqual(request.get_header("Authorization"), "Bearer fixture-secret")
            self.assertEqual(request.get_header("Chatgpt-account-id"), "fixture-account")
            self.assertEqual(
                json.loads(request.data),
                {
                    "id": "session-1",
                    "model": "fixture-model",
                    "commands": {
                        "search_query": [
                            {
                                "q": "Python 网络",
                                "recency": 7,
                                "domains": ["docs.python.org"],
                            }
                        ],
                        "response_length": "short",
                    },
                    "settings": {"allowed_callers": ["direct"], "external_web_access": True},
                    "max_output_tokens": 6000,
                },
            )
        self.assertEqual(
            json.loads(stdout),
            {
                "session_id": "session-1",
                "output": "原始文本\nciteturn0search0",
                "results": results,
            },
        )
        self.assertEqual(original, (self.auth.read_bytes(), self.auth.stat().st_mtime_ns))

    def test_dry_run_maps_operations_and_modes_without_auth_or_network(self):
        cases = [
            (["search", "one", "two"], "search_query", [{"q": "one"}, {"q": "two"}]),
            (
                ["fetch", "turn0search0", "--line", "0"],
                "open",
                [{"ref_id": "turn0search0", "lineno": 0}],
            ),
            (
                ["find", "turn1view0", "timeout"],
                "find",
                [{"ref_id": "turn1view0", "pattern": "timeout"}],
            ),
            (["click", "turn1view0", "2"], "click", [{"ref_id": "turn1view0", "id": 2}]),
        ]
        self.auth.unlink()
        with (
            patch.object(web, "auth_headers") as auth,
            patch.object(web, "build_opener") as network,
        ):
            for mode, access in [("cached", False), ("indexed", "indexed"), ("live", True)]:
                for args, key, expected in cases:
                    with self.subTest(mode=mode, action=key):
                        code, stdout, stderr = self.invoke(
                            "--dry-run",
                            "--session",
                            "same-session",
                            "--mode",
                            mode,
                            *args,
                        )
                        self.assertEqual((code, stderr), (0, ""))
                        request = json.loads(stdout)["request"]
                        self.assertEqual(request["commands"][key], expected)
                        self.assertEqual(request["settings"]["external_web_access"], access)
                        self.assertEqual(request["id"], "same-session")
                        self.assertNotIn("input", request)
            auth.assert_not_called()
            network.assert_not_called()

    def test_invalid_commands_fail_before_network(self):
        cases = [
            ["search", "a", "b", "c", "d", "e"],
            ["search", "a", "b", "c", "d"],
            ["search", " "],
            ["search", "q", "--recency", "-1"],
            ["fetch", "https://example.com", "--line", str(2**64)],
            ["fetch", "turn0search0"],
            ["fetch", "file:///etc/passwd"],
            ["fetch", "https://user:password@example.com"],
            ["click", "https://example.com", "1"],
            ["--max-output-tokens", "0", "search", "q"],
        ]
        with patch.object(web, "build_opener") as network:
            for args in cases:
                with self.subTest(args=args):
                    code, stdout, stderr = self.invoke(*args)
                    self.assertNotEqual(code, 0)
                    self.assertEqual(stdout, "")
                    self.assertTrue(stderr)
            network.assert_not_called()

    def test_model_precedence_and_missing_model(self):
        config_model = "fixture-model" if importlib.util.find_spec("tomllib") else None
        for env, flags, expected in [
            ({}, [], config_model),
            ({"CODEX_WEB_MODEL": "env-model"}, [], "env-model"),
            ({"CODEX_WEB_MODEL": "env-model"}, ["--model", "flag-model"], "flag-model"),
        ]:
            with (
                self.subTest(expected=expected),
                patch.dict(os.environ, {"CODEX_HOME": str(self.home), **env}, clear=True),
            ):
                code, stdout, stderr = self.invoke("--dry-run", *flags, "search", "q")
                if expected is None:
                    self.assertEqual((code, stdout), (1, ""))
                    self.assertIn("--model or CODEX_WEB_MODEL", json.loads(stderr)["error"])
                else:
                    self.assertEqual((code, stderr), (0, ""))
                    self.assertEqual(json.loads(stdout)["request"]["model"], expected)
        (self.home / "config.toml").unlink()
        with patch.dict(os.environ, {"CODEX_HOME": str(self.home)}, clear=True):
            self.assertEqual(self.invoke("--dry-run", "search", "q")[0], 1)
        with patch.dict(os.environ, {"CODEX_WEB_MODEL": " "}):
            self.assertEqual(self.invoke("--dry-run", "search", "q")[0], 1)

    def test_cli_starts_without_tomllib(self):
        # A startup import used to prevent even explicit models on older interpreters.
        runner = (
            "import runpy, sys; sys.modules['tomllib'] = None; "
            "runpy.run_path(sys.argv.pop(1), run_name='__main__')"
        )
        for env, flags, expected in [
            ({}, ["--model", "flag-model"], "flag-model"),
            ({"CODEX_WEB_MODEL": "env-model"}, [], "env-model"),
            ({}, [], None),
        ]:
            with self.subTest(expected=expected):
                result = subprocess.run(
                    [
                        sys.executable,
                        "-B",
                        "-c",
                        runner,
                        str(Path(web.__file__).resolve()),
                        "--dry-run",
                        *flags,
                        "search",
                        "q",
                    ],
                    env={"CODEX_HOME": str(self.home), **env},
                    capture_output=True,
                    text=True,
                    check=False,
                )
                if expected is None:
                    self.assertEqual((result.returncode, result.stdout), (1, ""))
                    self.assertIn("--model or CODEX_WEB_MODEL", json.loads(result.stderr)["error"])
                else:
                    self.assertEqual((result.returncode, result.stderr), (0, ""))
                    self.assertEqual(json.loads(result.stdout)["request"]["model"], expected)

    def test_invalid_credentials_fail_without_exposing_them(self):
        for data in [
            {"auth_mode": "apikey", "OPENAI_API_KEY": "fixture-secret"},
            {"auth_mode": "chatgpt", "tokens": None},
            {"auth_mode": "chatgpt", "tokens": {"access_token": "fixture-secret"}},
            {
                "auth_mode": "chatgpt",
                "tokens": {"access_token": "fixture-secret\n", "account_id": "fixture-account"},
            },
        ]:
            self.auth.write_text(json.dumps(data))
            with patch.object(web, "build_opener") as network:
                code, stdout, stderr = self.invoke("search", "q")
                self.assertEqual((code, stdout), (1, ""))
                self.assertNotIn("fixture-secret", stderr)
                self.assertNotIn("fixture-account", stderr)
                network.assert_not_called()

    def test_http_and_network_errors_are_redacted_and_not_retried(self):
        errors = [URLError("fixture-secret"), TimeoutError("fixture-secret")]
        errors += [
            HTTPError(
                web.ENDPOINT, status, "fixture-secret", Message(), io.BytesIO(b"fixture-secret")
            )
            for status in (401, 403, 404, 429, 500)
        ]
        for error in errors:
            with (
                self.subTest(error=type(error).__name__),
                patch.object(web, "build_opener") as opener,
            ):
                opener.return_value.open.side_effect = error
                code, stdout, stderr = self.invoke("search", "q")
                self.assertEqual((code, stdout), (1, ""))
                self.assertNotIn("fixture-secret", stderr)
                self.assertNotIn("fixture-account", stderr)
                self.assertIn("error", json.loads(stderr))
                opener.return_value.open.assert_called_once()

    def test_malformed_and_oversized_responses_fail(self):
        for raw in [b"not JSON", b"{}", b'{"output":"ok","results":{}}', b"x" * 129]:
            with self.subTest(raw=raw), patch.object(web, "MAX_RESPONSE_BYTES", 128):
                with patch.object(web, "build_opener") as opener:
                    opener.return_value.open.return_value = io.BytesIO(raw)
                    self.assertEqual(self.invoke("search", "q")[0], 1)
        for results in [None, []]:
            with patch.object(web, "build_opener") as opener:
                body = {"output": "ok"}
                if results is not None:
                    body["results"] = results
                opener.return_value.open.return_value = io.BytesIO(json.dumps(body).encode())
                code, stdout, _ = self.invoke("search", "q")
                self.assertEqual(code, 0)
                self.assertEqual(json.loads(stdout)["results"], results)

    def test_redirects_never_receive_credentials(self):
        # urllib normally follows redirects, which could send credentials to another host.
        paths = []

        class RedirectServer(BaseHTTPRequestHandler):
            def do_POST(self):
                paths.append(self.path)
                self.rfile.read(int(self.headers["Content-Length"]))
                self.send_response(int(self.path[1:]))
                self.send_header("Location", "/credential-leak")
                self.end_headers()

            def do_GET(self):
                paths.append(self.path)
                self.send_response(200)
                self.end_headers()

            def log_message(self, *args):
                pass

        server = HTTPServer(("127.0.0.1", 0), RedirectServer)
        thread = threading.Thread(target=server.serve_forever, kwargs={"poll_interval": 0.01})
        thread.start()
        try:
            for status in (301, 302, 303, 307, 308):
                with patch.object(
                    web, "ENDPOINT", f"http://127.0.0.1:{server.server_port}/{status}"
                ):
                    code, _, stderr = self.invoke("search", "q")
                    self.assertEqual(code, 1)
                    self.assertIn(f"HTTP {status}", stderr)
            self.assertEqual(paths, ["/301", "/302", "/303", "/307", "/308"])
        finally:
            server.shutdown()
            thread.join()
            server.server_close()


if __name__ == "__main__":
    unittest.main()
