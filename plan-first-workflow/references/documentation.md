# Project documentation impact and synchronization

Use this reference to keep project documentation aligned with a feature from planning through PR
readiness. Cover repository documentation such as README files, user guides, architecture docs,
plans, API references, examples, changelogs, and documentation indexes. Do not use this reference
as a source-code comment or API-docstring style guide.

## Discover the project's documentation system

Before deciding what to change:

1. Read the applicable repository instructions (`AGENTS.md`, `CLAUDE.md`, or equivalents).
2. Locate the documentation entry points and the documents closest to the changed behavior.
3. Inspect existing architecture and plan documents before creating a new one.
4. Locate tracked examples, changelogs, schemas, and documentation-generation or link-check scripts.
5. Identify generated files and update their source or run their generator instead of editing the
   generated output manually.
6. Follow the project's existing language, terminology, headings, status vocabulary, and file
   placement unless the approved plan intentionally changes them.

Do not assume every repository has every document type. Apply the project's own structure and
record a no-change rationale instead of creating ceremonial files with no established purpose.

## Assess documentation impact

Use the implementation's behavior and contracts to select affected documents:

| Change | Check and update when present |
| --- | --- |
| User-visible behavior, installation, workflow, or CLI | README/user guide and changelog |
| Configuration, schema, defaults, or environment variables | README/reference, tracked example, and changelog |
| Public API or error contract | API/reference and relevant architecture doc |
| Module responsibility, ownership, state, data flow, or dependency boundary | Architecture/design doc |
| Feature design, status, or material deviation from an approved design | Feature plan/design doc |
| Added, removed, or renamed documentation | Documentation index and inbound links |
| Internal refactor with no user, contract, or documented architecture impact | Usually no project-doc change; state why |

Treat the table as an impact map, not a requirement to touch every listed file. Prefer the narrowest
set that keeps the repository's current documentation truthful and discoverable.

## Preserve document roles

- Keep current-truth documents such as README, user guides, references, and architecture docs
  aligned with implemented behavior.
- Keep plan and design documents as decision records. Preserve their original background and
  intent; record implementation status, supersession, and material deviations explicitly instead
  of rewriting history.
- Keep examples canonical, runnable where practical, and free of real credentials or private data.
- Keep changelog entries user- or maintainer-relevant and follow the repository's existing format.
- Keep indexes synchronized when documents are added, removed, renamed, or reclassified.

Use code, tests, schemas, and validated runtime behavior as the source of truth for current
behavior. Do not treat an old plan as proof of what the product currently does.

## Write synchronized documentation

- Describe the actual behavior and its important boundaries, not the chronology of implementation.
- Distinguish user choices from fixed internal policy.
- Reuse established terms and exact identifiers for commands, fields, types, and states.
- Link to a single authoritative explanation instead of duplicating details across several files.
- Keep examples consistent with current commands, schemas, defaults, and output.
- Avoid claiming that unimplemented or unvalidated behavior is complete.
- Update or remove stale statements in the same change that invalidates them.

During Planning, update the plan and any index entry required to make it discoverable. Do not
preemptively change current-truth documentation to describe future behavior as already available.
During Implementation, synchronize affected current-truth documentation with what was actually
built. During Finishing, validate the complete documentation set against the final diff.

## Validate before PR readiness

1. Compare the final diff with the plan's documentation-impact assessment and account for scope
   changes.
2. Search for retired names, commands, configuration keys, paths, and contradictory descriptions.
3. Check links, headings, command examples, configuration examples, and code snippets affected by
   the change.
4. Run the repository's documentation generators, formatters, link checks, or documentation builds.
5. Confirm that generated indexes and tracked examples came from their prescribed source or script.
6. Confirm that plan status and recorded implementation deviations are honest after validation.
7. Re-read the documentation diff with the code, tests, and schema visible.

In the final handoff, list the project documents changed and the documentation checks run. If no
project documentation changed, give the concrete impact rationale rather than merely saying
"not needed."
