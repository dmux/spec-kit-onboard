# Changelog

## 2.1.0 — 2026-03-26

- Added `extension.yml` manifest in the spec-kit community extension format (schema v1.0)
- Added `catalog-entry.json` for submission to the spec-kit community catalog
- Added `.extensionignore` to exclude development-only files from extension packages
- Renamed `LICENSE.md` to `LICENSE` to comply with community publishing requirements
- `extension.json` retained for backwards compatibility with spec-kit v1.x installations

## 2.0.0 — 2026-03-26

- **Interactive quiz mode**: new `after-explain` hook suggests `/onboard quiz` automatically at the right moment (after reading ≥ 3 artifacts, after reading all specs of a feature, or after 7 days since last quiz) — no need to type the command manually
- **Question history**: `quiz_questions_history[]` added to the profile (schema v2.0); every question asked is persisted with artifact + topic fingerprint, guaranteeing no question is ever repeated across sessions
- **Multi-developer support**: `/onboard start` now creates per-developer profiles at `.onboard/profiles/<name>.json`; all commands resolve the active profile by name; legacy `profile.json` is migrated automatically; prompts to select a profile when multiple exist and `--dev` is not specified
- Profile schema bumped to v2.0: new fields `quiz_questions_history`, `implementation_attempts`, `last_mentor_suggestion`, `last_quiz_nudge`

## 1.2.0 — 2026-03-26

- New command `/onboard team`: aggregated view of all developer profiles in `.onboard/`; supports single and multi-profile layouts
- `/onboard team --report`: exports full team progress report to `.onboard/team-report.md` with per-developer sections, feature coverage, gaps, and recommendations
- `/onboard mentor` now integrates with `jira` and `azure-devops` extensions: appends linked issue/work item status and URL to the task briefing when available

## 1.1.0 — 2026-03-26

- `--format mermaid` in `/onboard trail`: interactive diagram with color coding by task status (green/blue/red), click handlers linking to task files, and subgraphs grouping completed vs open tasks
- docguard integration in `/onboard explain`: displays quality score and failing criteria before the explanation, integrated into the explanation body per developer level
- New hook `before-implement`: automatically tracks `spec-aware` badge by checking whether the developer has read all specs before starting implementation; displays a non-blocking advisory if specs are unread

## 1.0.0 — 2026-03-26

- Initial release
- 6 commands: `start`, `explain`, `trail`, `quiz`, `badge`, `mentor`
- 1 hook: `after-implement`
- 9 badges in the catalog
- Passive integration with `cleanup`, `verify`, `docguard`, `learn`
