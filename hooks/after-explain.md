# Hook: after-explain

## Event

`after-explain` — fires automatically after each `/onboard explain` execution.

---

## Agent instructions

You are executing the `after-explain` hook of the spec-kit-onboard extension. This hook enables the interactive quiz mode by suggesting a quiz at the right moment — without requiring the developer to type `/onboard quiz` manually. It **must never block the main flow**.

### Step 1 — Read the profile

Read the active developer profile (see multi-developer profile resolution in `commands/start.md`).

If no profile exists, exit silently.

### Step 2 — Evaluate quiz readiness

Calculate the current state:

- `artifacts_read_this_session`: count of items added to `explained_artifacts[]` since the last `quiz_history` entry date (or since `onboarded_at` if no quiz has been taken yet).
- `total_artifacts_read`: total length of `explained_artifacts[]`.
- `last_quiz_date`: date of the most recent entry in `quiz_history[]` (or null).
- `days_since_last_quiz`: days elapsed since `last_quiz_date` (or null if never taken).

### Step 3 — Decide whether to suggest a quiz

Suggest a quiz if **any** of the following conditions are met:

| Condition | Trigger |
| --- | --- |
| Developer has never taken a quiz AND has read ≥ 3 artifacts | First-time nudge |
| Developer read ≥ 5 new artifacts since last quiz | Knowledge refresh |
| Developer has read all specs of a feature (and has not quizzed on it yet) | Feature readiness check |
| ≥ 7 days have passed since the last quiz | Retention check |

If none of the conditions are met, exit silently.

### Step 4 — Display the interactive suggestion

Choose the message based on the trigger condition:

**First-time nudge:**

```text
⚑ onboard — ready for a knowledge check?

  You've read [N] artifacts. A quick quiz can confirm your understanding
  before you start implementing.

  Run /onboard quiz to start (5 questions, ~2 min).
```

**Knowledge refresh:**

```text
⚑ onboard — quiz suggestion

  You've read [N] new artifacts since your last quiz ([last quiz date]).
  A quick check will help identify any gaps before implementing.

  Run /onboard quiz to start.
```

**Feature readiness check:**

```text
⚑ onboard — you've read all specs for [feature]

  Run /onboard quiz --feature [feature] to validate your understanding
  before starting implementation.
```

**Retention check:**

```text
⚑ onboard — it's been [N] days since your last quiz

  Run /onboard quiz to refresh your understanding of the project.
```

### Step 5 — Suppress repeated nudges

To avoid annoying the developer with repeated suggestions:

1. Record the suggestion in a new profile field `last_quiz_nudge: ISO8601` after displaying it.
2. If `last_quiz_nudge` was set within the last 24 hours, exit silently regardless of conditions in Step 3.

---

## Behavioral guarantees

- **Do not block.** Exit silently on any error.
- **Do not repeat within 24 hours.** One nudge per day maximum.
- **Never start the quiz automatically.** This hook only suggests — it never runs `/onboard quiz` itself.
