#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0
# Derived from OpenAI Codex, Copyright 2025 OpenAI.
# Modified: translated the standalone search client to Python; see reference/source.md.
"""Search and fetch through Codex's alpha/search endpoint without a model session.

Run `python3 web.py --help`. Requires Python 3 and Codex ChatGPT file auth.
Only the supplied commands are sent; local conversation history is never read.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import uuid
from email.message import Message
from http.client import HTTPException
from pathlib import Path
from typing import IO
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, Request, build_opener

ENDPOINT = "https://chatgpt.com/backend-api/codex/alpha/search"
MAX_RESPONSE_BYTES = 8 * 1024 * 1024
TIMEOUT_SECONDS = 60
WEB_ACCESS: dict[str, bool | str] = {"cached": False, "indexed": "indexed", "live": True}


class WebError(Exception):
    """An operational failure safe to display without credentials or server bodies."""


class NoRedirect(HTTPRedirectHandler):
    """Never forward an authenticated request to a redirect destination."""

    def redirect_request(
        self,
        req: Request,
        fp: IO[bytes],
        code: int,
        msg: str,
        headers: Message,
        newurl: str,
    ) -> None:
        return None


def nonempty(value: str) -> str:
    if not value.strip():
        raise argparse.ArgumentTypeError("must not be empty")
    return value


def unsigned(value: str) -> int:
    try:
        number = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError("must be an unsigned integer") from None
    if not 0 <= number <= 2**64 - 1:
        raise argparse.ArgumentTypeError("must be between 0 and 2^64 - 1")
    return number


def domain(value: str) -> str:
    value = value.strip().lower().rstrip(".")
    if not re.fullmatch(r"[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?", value):
        raise argparse.ArgumentTypeError("use a domain such as docs.python.org, without a URL path")
    return value


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=nonempty, help="overrides CODEX_WEB_MODEL and Codex config")
    parser.add_argument(
        "--session", type=nonempty, help="reuse the session_id from an earlier result"
    )
    parser.add_argument("--mode", choices=WEB_ACCESS, default="cached")
    parser.add_argument("--length", choices=("short", "medium", "long"), default="short")
    parser.add_argument("--max-output-tokens", type=unsigned, default=6000)
    parser.add_argument(
        "--dry-run", action="store_true", help="print payload; no auth read or network"
    )
    actions = parser.add_subparsers(dest="action", required=True)
    search = actions.add_parser("search", help="search up to four queries")
    search.add_argument("queries", nargs="+", type=nonempty)
    search.add_argument("--recency", type=unsigned, help="number of recent days")
    search.add_argument("--domain", dest="domains", action="append", type=domain)
    fetch = actions.add_parser("fetch", help="open public URLs or earlier result reference IDs")
    fetch.add_argument("refs", nargs="+", type=nonempty)
    fetch.add_argument("--line", type=unsigned, help="start at this line in each page")
    find = actions.add_parser("find", help="find text in a public URL or earlier page")
    find.add_argument("ref", type=nonempty)
    find.add_argument("pattern", type=nonempty)
    click = actions.add_parser("click", help="open a numbered link from an earlier page")
    click.add_argument("ref", type=nonempty)
    click.add_argument("link_id", type=unsigned)
    args = parser.parse_args(argv)
    if args.max_output_tokens == 0:
        parser.error("--max-output-tokens must be positive")
    if args.action == "search":
        if len(args.queries) > 4:
            parser.error("at most four queries per call")
        if len(args.queries) == 4 and args.length == "short":
            parser.error("four queries require --length medium or long")
    return args


def resolve_model(explicit: str | None, home: Path) -> str:
    """Resolve only a model name, never provider endpoints, headers or credentials."""
    model = explicit or os.environ.get("CODEX_WEB_MODEL")
    if model is not None:
        if not model.strip():
            raise WebError("--model and CODEX_WEB_MODEL must not be blank.")
        return model.strip()
    try:
        import tomllib
    except ModuleNotFoundError:
        raise WebError(
            "TOML config reading is unavailable; specify --model or CODEX_WEB_MODEL."
        ) from None
    try:
        with (home / "config.toml").open("rb") as stream:
            config = tomllib.load(stream)
    except FileNotFoundError:
        config = {}
    except (OSError, ValueError):
        raise WebError("Cannot read Codex config.toml; supply --model explicitly.") from None
    model = config.get("model")
    if not isinstance(model, str) or not model.strip():
        raise WebError("Specify --model or CODEX_WEB_MODEL; no top-level model in Codex config.")
    return model.strip()


def auth_headers(home: Path) -> dict[str, str]:
    """Read existing ChatGPT file auth without refreshing, exporting or modifying it."""
    try:
        data: object = json.loads((home / "auth.json").read_text(encoding="utf-8"))
    except FileNotFoundError:
        raise WebError(
            "Codex auth.json not found. ChatGPT file login is required; keychain auth is not read."
        ) from None
    except (OSError, ValueError):
        raise WebError("Cannot read Codex auth.json. Check the Codex login locally.") from None
    if not isinstance(data, dict) or data.get("auth_mode") != "chatgpt":
        raise WebError("Only Codex ChatGPT file auth is supported; API keys are not used.")
    tokens = data.get("tokens")
    if not isinstance(tokens, dict):
        raise WebError("Codex ChatGPT tokens are missing. Run codex login locally.")
    token = tokens.get("access_token")
    account = tokens.get("account_id")
    if not isinstance(token, str) or not isinstance(account, str):
        raise WebError("Codex access token or account ID is missing. Run codex login locally.")
    for value in (token, account):
        if not value or not all(33 <= ord(c) <= 126 for c in value):
            raise WebError(
                "Codex access token or account ID is malformed. Run codex login locally."
            )
    return {"Authorization": f"Bearer {token}", "ChatGPT-Account-ID": account}


def validate_ref(ref: str, session: str | None) -> None:
    """Keep remote reference IDs tied to an explicit session and reject non-web URLs."""
    try:
        url = urlsplit(ref)
        if url.scheme:
            if (
                url.scheme not in ("http", "https")
                or not url.hostname
                or url.username
                or url.password
            ):
                raise WebError("Use a public HTTP(S) URL without embedded credentials.")
        elif not session:
            raise WebError("A result reference requires --session from its earlier result.")
    except ValueError:
        raise WebError("Malformed URL or reference.") from None


def build_request(args: argparse.Namespace, model: str) -> dict[str, object]:
    """Translate the supported SearchCommands subset and Codex's mode mapping."""
    commands: dict[str, object] = {"response_length": args.length}
    if args.action == "search":
        queries: list[dict[str, object]] = []
        for text in args.queries:
            query: dict[str, object] = {"q": text}
            if args.recency is not None:
                query["recency"] = args.recency
            if args.domains:
                query["domains"] = args.domains
            queries.append(query)
        commands["search_query"] = queries
    elif args.action == "fetch":
        pages: list[dict[str, object]] = []
        for ref in args.refs:
            validate_ref(ref, args.session)
            page: dict[str, object] = {"ref_id": ref}
            if args.line is not None:
                page["lineno"] = args.line
            pages.append(page)
        commands["open"] = pages
    else:
        validate_ref(args.ref, args.session)
        if args.action == "find":
            commands["find"] = [{"ref_id": args.ref, "pattern": args.pattern}]
        else:
            if not args.session:
                raise WebError(
                    "click requires --session from the page containing the numbered link."
                )
            commands["click"] = [{"ref_id": args.ref, "id": args.link_id}]
    return {
        "id": args.session or str(uuid.uuid4()),
        "model": model,
        "commands": commands,
        "settings": {"allowed_callers": ["direct"], "external_web_access": WEB_ACCESS[args.mode]},
        "max_output_tokens": args.max_output_tokens,
    }


def search(request: dict[str, object], headers: dict[str, str]) -> dict[str, object]:
    """Execute one request without retries; preserve server text and structured results."""
    http_request = Request(
        ENDPOINT,
        data=json.dumps(request, ensure_ascii=False).encode("utf-8"),
        headers={
            **headers,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "User-Agent": "codex-web-skill/1.0",
        },
        method="POST",
    )
    try:
        with build_opener(NoRedirect()).open(http_request, timeout=TIMEOUT_SECONDS) as response:
            raw = response.read(MAX_RESPONSE_BYTES + 1)
    except HTTPError as error:
        status = error.code
        error.close()
        hints = {
            401: "Codex credentials may have expired; refresh the login with Codex itself.",
            403: "The service denied access; account permission or gateway restrictions may apply.",
            404: "The alpha/search endpoint is unavailable for this account or service version.",
            429: "Rate limited; wait before making another call.",
        }
        hint = (
            "Redirects are refused to protect credentials."
            if 300 <= status < 400
            else hints.get(status, "The search service rejected the request.")
        )
        # Error bodies and exception strings can echo credentials or proxy URLs.
        raise WebError(f"HTTP {status}. {hint}") from None
    except (URLError, OSError, HTTPException):
        raise WebError(
            "Network/TLS failure. Check connectivity and trusted proxies; no retry was made."
        ) from None
    if len(raw) > MAX_RESPONSE_BYTES:
        raise WebError("Search response exceeds the 8 MiB limit.")
    try:
        data: object = json.loads(raw)
    except (ValueError, UnicodeError):
        raise WebError("The search service returned invalid JSON.") from None
    if not isinstance(data, dict) or not isinstance(data.get("output"), str):
        raise WebError("The search response is missing its text output.")
    results = data.get("results")
    if results is not None and not isinstance(results, list):
        raise WebError("The search response has malformed structured results.")
    return {"session_id": request["id"], "output": data["output"], "results": results}


def main(argv: list[str] | None = None) -> int:
    """Write one JSON result to stdout; operational errors go to stderr with exit 1."""
    args = parse_args(argv)
    home = Path(os.environ.get("CODEX_HOME", "~/.codex")).expanduser()
    try:
        request = build_request(args, resolve_model(args.model, home))
        if args.dry_run:
            result: dict[str, object] = {"endpoint": ENDPOINT, "request": request}
        else:
            result = search(request, auth_headers(home))
    except WebError as error:
        print(json.dumps({"error": str(error)}, ensure_ascii=False), file=sys.stderr)
        return 1
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
