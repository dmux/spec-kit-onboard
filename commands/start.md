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

### Step 2 — Create the developer profile

Check whether `.onboard/profile.json` already exists.

- **If it does not exist:** create `.onboard/profile.json` by copying `templates/profile.json` (path relative to the extension) and filling in:
  - `developer.name` → value of `--dev` (default: `"developer"`)
  - `developer.level` → value of `--level` (default: `"junior"`)
  - `developer.onboarded_at` → current ISO8601 timestamp
  - `last_updated` → current ISO8601 timestamp

- **If it already exists:** update only `developer.name` and `developer.level` if the parameters were explicitly provided. Preserve all progress history. Update `last_updated`.

### Step 3 — Generate the guide `.onboard/guide.md`

Generate the file `.onboard/guide.md` with the sections below. Use language calibrated to the profile `level`:

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

### Step 4 — Terminal output

Display the following summary:

```text
✦ onboard — guide generated at .onboard/guide.md

  Project: [project name]
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
