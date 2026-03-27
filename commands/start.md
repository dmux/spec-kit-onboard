# Command: /onboard start

## Syntax

```bash
/onboard start [--dev <name>] [--level <junior|mid|senior>]
```

## Parameters

- `--dev`: developer name (default: `"developer"`)
- `--level`: declared level — `junior` (default), `mid`, or `senior`

---

## Agent instructions

You are executing the `/onboard start` command of the spec-kit-onboard extension. Follow the steps below in exact order.

### Step 1 — Required context reading

Read the following artifacts:

1. `memory.md` — general project context (required; if missing, note it and continue)
2. `.speckit/extensions.json` — installed extensions (required; if missing, treat as empty list)
3. `features/*/spec.md` — specs of all found features
4. `features/*/tasks.md` — tasks and status of all found features

**Context limit:** read at most 3 complete features. For projects with more, prioritize:

  1. Features with tasks in "in progress" status
  2. Most recently modified features

If the project has no features, continue — the guide will be generated based solely on `memory.md` and installed extensions.

### Step 2 — Multi-developer profile resolution

v2.0 supports multiple developers working simultaneously on the same project. Profiles are stored per-developer:

**Profile storage layout:**

```text
.onboard/
├── profile.json              — legacy single-developer profile (v1.x)
└── profiles/
    └── <normalized-name>.json — per-developer profile (v2.0+)
```

**Name normalization:** convert `--dev` value to lowercase, replace spaces with hyphens (e.g., `"Maria Silva"` → `maria-silva`).

**Resolution logic:**

1. If `--dev <name>` is provided:
   - Look for `.onboard/profiles/<normalized-name>.json`.
   - If not found, create a new profile at that path from `templates/profile.json`.
   - If the legacy `.onboard/profile.json` exists and contains a matching `developer.name`, migrate it to `.onboard/profiles/<normalized-name>.json` and delete the legacy file.

2. If `--dev` is **not** provided:
   - Count profiles in `.onboard/profiles/`.
   - **Zero profiles:** also check for legacy `.onboard/profile.json`. If found, use it. If not, create `.onboard/profiles/developer.json` with default values and inform: "Profile created for 'developer'. Use `--dev <your-name>` to personalize."
   - **One profile:** use it automatically and display: "Using profile: [developer name]."
   - **Multiple profiles:** list them and ask the developer to re-run with `--dev <name>`:

```text
⚠ Multiple developer profiles found. Please specify one:

  /onboard start --dev "[name 1]"
  /onboard start --dev "[name 2]"
  /onboard start --dev "[name 3]"
```

**Profile path used by all other commands:** every command and hook in this extension must follow the same resolution logic above when reading or writing the profile. The resolved path is referred to as the "active profile" throughout these instructions.

### Step 3 — Create or update the active profile

- **If the profile does not exist:** create it from `templates/profile.json` and fill in:
  - `developer.name` → value of `--dev` (default: `"developer"`)
  - `developer.level` → value of `--level` (default: `"junior"`)
  - `developer.onboarded_at` → current ISO8601 timestamp
  - `last_updated` → current ISO8601 timestamp

- **If it already exists:** update only `developer.name` and `developer.level` if the parameters were explicitly provided. Preserve all progress history. Update `last_updated`.

### Step 4 — Generate the guide `.onboard/guide.md`

Generate `.onboard/guide.md` with the sections below. Use language calibrated to the profile `level`:

- `junior`: accessible language, analogies, explains SDD terms on first use, full glossary
- `mid`: direct technical language, focuses on practical consequences
- `senior`: dense and direct, focuses on current state, what changed, architectural decisions

**Required sections:**

#### 1. Header

```markdown
# Onboarding guide — [project name, extracted from memory.md or folder name]

Generated at: [date]  |  Developer: [name]  |  Level: [level]
```

#### 2. What this project is

Plain-language summary based on `memory.md`. Maximum 3 paragraphs.

#### 3. How the workflow works here

Explain the SDD cycle adapted to the installed extensions. Explicitly mention what happens when a task is implemented (which hooks fire, which validations occur).

If `learn` is installed, include: "After implementing each feature, use `/learn guide` to consolidate what you learned."

#### 4. Features in progress

For each feature found:

```markdown
### [feature name] — [status: in progress / planned / completed]
[spec summary in 2–3 sentences]
Open tasks: N  |  Next: [task-id and title]
```

If no features exist, write: "No features found. The project is in its initial phase."

#### 5. Where to start

List 3 to 5 recommended entry-point tasks, ordered by suitability to the declared level. For each:

```text
1. [task-id] · [title] — [feature]
   Why: [one-sentence justification based on level and dependencies]
```

For `junior`: prioritize low-complexity tasks without dependencies.
For `mid`: prioritize medium-complexity tasks.
For `senior`: prioritize highest-impact or highest-complexity tasks.

#### 6. Project glossary

Include only SDD terms that appear in the artifacts read. For each term, explain it in the context of this specific project (not generic definitions).

Terms to include if present: `spec`, `task`, `hook`, `drift`, `feature`, `plan`, names of installed extensions.

Omit this section for `senior` level.

#### 7. Active extensions and how they affect your day-to-day

Table with each installed extension and what it concretely does during the development cycle.

### Step 5 — Terminal output

Display the following summary:

```text
✦ onboard — guide generated at .onboard/guide.md

  Project: [project name]  |  Developer: [name]
  Open features: N  |  Pending tasks: N  |  Extensions: N

  Recommended next steps:
    1. Read .onboard/guide.md for the full context
    2. Run /onboard trail <feature> to see dependencies
    3. Run /onboard quiz when you feel ready

  Tip: use /onboard explain <file> at any time.
```

---

## Principles to follow

1. **Never invent information about the project.** If an artifact cannot be read, state: "Could not find [file] — continuing without it."
2. **Don't repeat what the dev already knows.** If the profile already existed, mention only what is new since the last onboarding.
3. **End with an action.** The terminal output always suggests a concrete next step.
4. **All generated files go inside `.onboard/`.** Never create files outside that directory.
5. **Multi-developer safety.** Never overwrite another developer's profile. Always resolve the active profile before writing.
