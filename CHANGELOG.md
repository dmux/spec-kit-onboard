# Changelog

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
