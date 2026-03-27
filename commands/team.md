# Command: /onboard team

## Syntax

```bash
/onboard team [--report] [--dev <name>]
```

## Parameters

- `--report`: export a full team progress report to `.onboard/team-report.md`
- `--dev <name>`: filter output to a specific developer's profile

---

## Agent instructions

You are executing the `/onboard team` command of the spec-kit-onboard extension.

### Step 1 — Discover all developer profiles

Scan the `.onboard/` directory for all `profile.json` files. The expected layout is:

```text
.onboard/
├── profile.json              — single-developer setup (legacy)
└── profiles/
    ├── <name>.profile.json   — per-developer profiles
    └── ...
```

Support both layouts:

- **Single profile** (`.onboard/profile.json`): treat as a one-person team.
- **Multi-profile** (`.onboard/profiles/*.profile.json`): load all files found.

If no profiles are found, respond: "No developer profiles found. Each team member should run `/onboard start --dev <name>` to create their profile."

If `--dev <name>` is provided, filter to only that developer's profile.

### Step 2 — Aggregate team data

For each profile loaded, extract:

- Developer name and level
- `tasks_completed[]` count
- `explained_artifacts[]` count
- `trails_generated[]` count
- `quiz_history`: best score and latest score
- `badges.earned[]` count and list
- `last_updated` timestamp

### Step 3 — Display the team overview (without `--report`)

```text
✦ team — [N] developer(s)

  Developer        Level     Tasks   Badges   Last active
  ───────────────────────────────────────────────────────
  [name]           [level]   [N]     [N]/9    [date]
  [name]           [level]   [N]     [N]/9    [date]

  Most active:    [name] — [N] tasks completed
  Most prepared:  [name] — [N] artifacts read, best quiz score [N]/5
  Most badged:    [name] — [N]/9 badges earned

  Run /onboard team --report to export the full report.
```

If only one developer: omit the comparison summary lines.

### Step 4 — Generate the report (with `--report`)

Generate `.onboard/team-report.md` using the template at `templates/team-report.md`.

Populate each section:

**Header:** project name (from `memory.md`), generation date, number of developers.

**Per-developer section:** for each profile, sorted by `tasks_completed` descending:

- Name, level, onboarding date
- Tasks completed (list with feature context)
- Artifacts explained (count + list of unique features covered)
- Quiz history: scores over time, identified gaps
- Badges earned and locked (with progress on locked ones)
- Trails generated

**Team summary section:**

- Total tasks completed across the team
- Features with full coverage (at least one developer has read all specs)
- Features with no coverage (no developer has read the spec)
- Developers who have not onboarded yet (no profile found — infer from `features/*/tasks.md` assignments if available)
- Average quiz score across the team

After generating, display:

```text
✦ team — report exported to .onboard/team-report.md

  Developers: [N]  |  Total tasks completed: [N]  |  Features covered: [N/total]
```

---

## Principles to follow

1. **Never invent data.** Only report what is in the profile files. If a field is missing, show `—`.
2. **Respect privacy.** This command reads local files only — nothing is sent externally.
3. **Be concise in the terminal.** The full detail goes into the report file, not the terminal output.
4. **Single-developer projects:** if only one profile exists, still generate a valid report — just skip team comparison sections.
