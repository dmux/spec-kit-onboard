# Hook: after-implement

## Event

`after-implement` — fires automatically after each completed implementation cycle in spec-kit.

---

## Agent instructions

You are executing the `after-implement` hook of the spec-kit-onboard extension. This hook **must never block the main flow**. If any step fails due to a read error, missing file, or any other reason, emit a warning and continue. If the entire hook fails, emit: `⚠ onboard/after-implement: error updating profile. Continue normally.` and exit without blocking.

### Step 1 — Identify the completed task

Detect which task was marked as completed in this cycle. spec-kit should provide the task context via environment variables or hook context. Try to obtain:

- Task ID (e.g., `T-003`)
- Feature it belongs to (e.g., `auth`)
- Full path: `feature/task-id` (e.g., `auth/T-003`)

If the task cannot be identified, emit `⚠ onboard: task not identified` and exit.

### Step 2 — Read the profile

Read `.onboard/profile.json`.

If it does not exist: exit silently (the dev has not onboarded yet — do not block).

### Step 3 — Check cleanup result (if installed)

Check whether `cleanup` is listed in `.speckit/extensions.json`.

If so: try to read the cleanup result for this task (file or output provided by the cleanup hook, if available). Note:

- `cleanup_passed`: `true` if there were no issues, `false` if there were issues
- If the result cannot be read, assume `cleanup_passed: null` (indeterminate) and continue.

This read is **passive** — never interfere with the cleanup execution.

### Step 4 — Update the profile

Make the following updates to `.onboard/profile.json`:

1. Add `"feature/task-id"` to the `tasks_completed[]` array, if not already there.
2. Update `last_updated`.

**Check `consecutive_mentor_follows`:**
Compare the completed task with the `last_mentor_suggestion` field in the profile (if it exists).

- If they match: the dev followed the mentor's suggestion — `consecutive_mentor_follows` was already incremented by the `mentor` command. Keep it.
- If they do not match: the dev implemented a different task than suggested — reset `consecutive_mentor_follows` to 0.

### Step 5 — Calculate unlocked badges

Check each badge still in `locked` and apply the rules:

**`first-task`:**

- Condition: `tasks_completed.length >= 1`
- If unlocked: move from `locked` to `earned`.

**`clean-pass`:**

- Condition: `cleanup` is installed AND `cleanup_passed == true`
- If unlocked: move from `locked` to `earned`.

**`mentor-streak`:**

- Condition: `consecutive_mentor_follows >= 3`
- If unlocked (and not already in `earned`): move from `locked` to `earned`.

**`autonomous`:**

- Condition: identify whether the feature of the completed task is fully done (all tasks in the feature are in `tasks_completed`).
  - If so: check whether no `/onboard explain` was run on artifacts of this feature during this cycle. This check is approximate — verify that all items in `explained_artifacts` belonging to this feature were already present **before** the first task of this feature was completed.
  - This is the hardest badge to calculate. If it cannot be determined with certainty, **do not grant the badge** (prefer a false negative).
- If unlocked: move from `locked` to `earned`.

### Step 6 — Display the summary

```text
✦ onboard — cycle complete

  Task: [task-id] · [title]  [[feature]]
  [if cleanup is installed:]
  Cleanup result: [✓ no issues → badge "clean-pass" unlocked! | ✗ issues found | ⚠ result unavailable]

  [for each badge unlocked in this cycle:]
  🏅 [badge-id] unlocked!

  Run /onboard mentor for the next suggestion.
```

If no badge was unlocked in this cycle, omit the badge line and display only:

```text
✦ onboard — cycle complete

  Task: [task-id] · [title]  [[feature]]

  Run /onboard mentor for the next suggestion.
```

---

## Behavioral guarantees

- **Do not block.** Any error in any step results in a warning + exit, never a failure of the main flow.
- **No duplicates.** Never add the same task twice to `tasks_completed`.
- **No invention.** Never grant badges without verifying the conditions.
- **Be silent when there is nothing to do.** If the dev has no profile, exit without output.
