# Command: /onboard explain

## Syntax

```bash
/onboard explain <target>
```

## Parameters

- `<target>` (required): file path, feature name, task name, or SDD concept

---

## Agent instructions

You are executing the `/onboard explain` command of the spec-kit-onboard extension. Follow the steps below.

### Step 1 — Read the profile

Read `.onboard/profile.json`.

- If it does not exist: create the profile with default values (name: `"developer"`, level: `"junior"`, current timestamps, empty lists, all badges in `locked`). Continue normally.
- Note the developer's `level` — it calibrates the entire explanation.

### Step 2 — Detect the target type

Determine the type of the provided `<target>`:

**A. File path** (contains `/` or ends in `.md`, `.json`, etc.)

- Try to read the file at the exact path provided.
- If not found: respond exactly with: "Could not find `[target]`. Check the path or run `/onboard start` to list available artifacts."
- If found: generate a contextual explanation of the content (see Step 3).

**B. Feature name** (matches a folder in `features/`)

- Read `features/<target>/spec.md`, `features/<target>/tasks.md`, and `features/<target>/plan.md` (if they exist).
- If the folder does not exist: respond: "Feature `[target]` not found. Available features: [list folders in features/]."
- Generate a feature summary: spec in plain language, open tasks, next unblocked task, external dependencies mentioned in the spec.

**C. SDD concept** (words like `spec`, `task`, `hook`, `drift`, `feature`, `plan`, `cleanup`, or the name of an installed extension)

- Explain the concept using examples extracted from the real project artifacts.
- Never give generic definitions disconnected from the current project.
- If the concept does not appear in any artifact read, say: "This concept does not appear in the artifacts read so far. Here is the general definition: [brief explanation]."

### Step 3 — Generate the explanation

Calibrate the explanation to the profile `level`:

**junior:**

- Use everyday analogies for technical concepts.
- Explain all SDD jargon on first mention.
- Include concrete examples from the project.
- Avoid assumptions about prior knowledge.

**mid:**

- Direct technical explanation.
- Focus on practical consequences: "what this means for what you're about to implement."
- Reference specific artifacts (file name + relevant section).

**senior:**

- Dense summary, maximum 3 paragraphs.
- Focus on implications, edge cases, and design decisions.
- Mention only what is non-obvious.

**Integration with docguard (if installed):**

If `docguard` is listed in `.speckit/extensions.json` and the target is a spec file (type A or B):

1. Read the docguard score for the spec. The score is typically stored in `.speckit/docguard/<feature>.json` or equivalent — check the docguard extension's output path.
2. Display the quality block **before** the explanation body:

```text
  docguard score: [score]/100
  [if score < 80:]
  Criteria not met:
    ✗ [criterion name] — [brief description of what's missing]
    ✗ [criterion name] — [brief description]
  [if score >= 80:]
  All major criteria met.
```

<!-- list continues after code block -->

1. Integrate the failing criteria into the explanation itself:
   - For `junior`: explain in plain language why each failing criterion matters and how to fix it.
   - For `mid`: reference the failing criteria as "things to address before implementing."
   - For `senior`: list failing criteria as a brief checklist at the end of the explanation.

1. If the docguard score file cannot be read, display: `docguard: score unavailable` and continue with the explanation.

If `docguard` is **not** installed, omit this block entirely.

### Step 4 — Mandatory closing

Always end with:

```text
What else would you like to understand about this?

Suggestions:
  → /onboard explain [related deeper topic 1]
  → /onboard explain [related deeper topic 2]
```

Choose suggestions that make sense in the context of what was explained (not generic ones).

### Step 5 — Update the profile

Update `.onboard/profile.json`:

1. Add the artifact path (or `"concept:<name>"` for SDD concepts) to the `explained_artifacts[]` array, if not already there.
2. Update `last_updated` with the current timestamp.
3. **Badge `first-read`:** if `explained_artifacts` had length 0 before this execution and now has 1, move `"first-read"` from `locked` to `earned`.
4. **Badge `spec-aware`:** check if all specs of any feature have been explained before any task of that feature was completed. If so, and the badge has not been earned yet, move `"spec-aware"` from `locked` to `earned` and notify the developer.

If a new badge was unlocked, display:

```text
🏅 Badge unlocked: [badge-name]
```

---

## Principles to follow

1. **Never invent information about the project.** Every statement must be verifiable in the artifacts read.
2. **Always calibrate to the profile level.** The same spec explained to a junior and to a senior should differ in density and vocabulary.
3. **Don't repeat what the dev already knows.** If the artifact is already in `explained_artifacts`, acknowledge it: "You've read this before. Here's a deeper look:" and focus on aspects not previously covered.
4. **Be concise in the terminal.** The explanation goes directly to the terminal — no separate file is generated.
