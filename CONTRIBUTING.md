# Contributing to spec-kit-onboard

Thanks for your interest. Contributions are welcome — bug reports, feature requests, and PRs alike.

## Reporting issues

Use the GitHub issue templates:

- **Bug report** — something isn't working as documented
- **Feature request** — a new capability or improvement

Before opening an issue, check if it already exists.

## Submitting a pull request

1. Fork the repository and create a branch from `main`
2. Make your changes
3. Run the linter: `make lint`
4. Open a PR with a clear description of what changed and why

## What can be changed

This extension is implemented as a set of Markdown instruction files — no compiled code. Changes fall into three categories:

| Area | Files |
| --- | --- |
| Command behavior | `commands/*.md` |
| Hook behavior | `hooks/*.md` |
| Output templates | `templates/*.md`, `templates/*.json` |

If you're changing command behavior, make sure the output format and profile fields stay consistent with the other commands that read from the same profile fields.

## Extension manifest

`extension.json` and `extension.yml` are the extension manifests. If you add a new command or hook, update both files. `extension.json` is the legacy format (spec-kit v1.x); `extension.yml` is the current format.

## Versioning

This project follows [Semantic Versioning](https://semver.org):

- `patch` — bug fixes, wording improvements, no behavior change
- `minor` — new flags, new integrations, backward-compatible additions
- `major` — breaking changes to profile schema, command syntax, or output format

Update `CHANGELOG.md` with a brief description of changes under the new version.

## Questions

Open a [discussion](https://github.com/dmux/spec-kit-onboard/discussions) or a GitHub issue if you're unsure whether something is worth a PR.
