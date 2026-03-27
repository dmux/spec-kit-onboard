# Hook: before-implement

## Event

`before-implement` — fires automatically before each implementation cycle begins in spec-kit.

---

## Agent instructions

You are executing the `before-implement` hook of the spec-kit-onboard extension. This hook **must never block the main flow**. If any step fails, emit a warning and continue. If the entire hook fails, emit: `⚠ onboard/before-implement: error checking readiness. Continue normally.` and exit without blocking.

### Step 1 — Identify the task about to be implemented

Detect which task the developer is about to start. spec-kit should provide the task context via environment variables or hook context. Try to obtain:

- Task ID (e.g., `T-003`)
- Feature it belongs to (e.g., `auth`)

If the task cannot be identified, exit silently.

### Step 2 — Read the profile

Read `.onboard/profile.json`.

If it does not exist: exit silently (the dev has not onboarded yet — do not block).

### Step 3 — Check spec readiness for the feature

Determine whether the developer has read the spec(s) for the feature they are about to implement.

1. List all spec files for the feature: `features/<feature>/spec.md` (and any other `*.spec.md` or linked specs referenced inside it).
2. Check which of those spec paths are present in `explained_artifacts[]` in the profile.
3. Calculate: `specs_read / specs_total` for this feature.

### Step 4 — Display readiness feedback

**If all specs for the feature have been read** (`specs_read == specs_total`):

Exit silently — the developer is ready.

**If some specs have not been read** (`specs_read < specs_total`):

Display a non-blocking advisory:

```text
⚑ onboard — spec check for [feature]

  You haven't read all specs for this feature yet.
  Read before implementing:
    [list of unread spec files]

  Run /onboard explain [spec] to get up to speed.
  (Proceeding anyway — this is just a reminder.)
```

**If no specs have been read at all** (`specs_read == 0`):

Display a stronger advisory:

```text
⚑ onboard — heads up before you start

  You haven't read the spec for [feature] yet.
  Implementing without reading the spec risks diverging from requirements.

  Run: /onboard explain features/[feature]/spec.md

  (Proceeding anyway — this is just a reminder.)
```

### Step 5 — Update the profile and track spec-aware badge

Update `.onboard/profile.json`:

1. Record this implementation attempt in a new field `implementation_attempts[]` (append `"feature/task-id"` with a timestamp). This is used to determine whether specs were read *before* any implementation attempt on a feature.
2. Update `last_updated`.

**Badge `spec-aware` — automatic tracking:**

Check the condition:

- All spec files for the feature are in `explained_artifacts[]`
- AND no entry in `implementation_attempts[]` for this feature exists **before** this current attempt (i.e., this is the first attempt on this feature)
- AND the badge has not been earned yet

If all conditions are met: move `"spec-aware"` from `locked` to `earned` in the profile.

If the badge was just unlocked, display:

```text
🏅 Badge unlocked: spec-aware — Read all specs before implementing!
```

---

## Behavioral guarantees

- **Do not block.** This hook is advisory only. The developer can always proceed without reading the spec.
- **Do not repeat.** If the developer has already seen the reminder for this feature (check `implementation_attempts[]`), display only a one-line reminder instead of the full advisory.
- **Be silent when there is nothing to do.** If the dev has no profile, or all specs are already read, exit without output.
