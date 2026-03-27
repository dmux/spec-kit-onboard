# Command: /onboard mentor

## Syntax

```bash
/onboard mentor [--feature <name>]
```

## Parameters

- `--feature`: restrict the suggestion to a specific feature (default: all open features)

---

## Agent instructions

You are executing the `/onboard mentor` command of the spec-kit-onboard extension.

### Step 1 — Read context

1. Read `.onboard/profile.json`. If it does not exist, create it with default values and instruct: "Run `/onboard start` to personalize your profile."
2. Read `features/*/tasks.md` of the features in scope (all, or the one specified by `--feature`).
3. Read `features/*/spec.md` of the features in scope (for briefing context).
4. Note from the profile: `level`, `tasks_completed`, `explained_artifacts`, `trails_generated`, `quiz_history[-1].gaps` (if any).

### Step 2 — Filter eligible tasks

Build the list of candidate tasks:

- **Include**: tasks with open status (`[ ]`)
- **Mandatory exclusions**: tasks with unresolved dependencies (tasks listed in `blocked-by` or `depends-on` that are still open)
- **Exclude**: tasks already present in `tasks_completed` in the profile

If no eligible task is found, respond: "No tasks available right now. All open tasks are blocked by dependencies or have already been completed."

### Step 3 — Scoring algorithm

For each eligible task, calculate a score:

```text
score = 0

// Level fit
IF level == "junior" AND task.complexity == "low":    score += 3
IF level == "junior" AND task.complexity == "medium": score += 1
IF level == "junior" AND task.complexity == "high":   score += 0
IF level == "mid"    AND task.complexity == "medium": score += 3
IF level == "mid"    AND task.complexity == "high":   score += 1
IF level == "mid"    AND task.complexity == "low":    score += 1
IF level == "senior":                                 score += complexity_value
  // complexity_value: low=1, medium=2, high=3

// Natural progression
IF task is a direct follow-up of a task already in tasks_completed: score += 4
  // "direct follow-up" = task whose depends-on points to a completed task

// Quiz gaps (avoids tasks in areas where dev showed gaps)
IF task.topics or task.feature intersects quiz_history[-1].gaps: score -= 1

// Already-read artifacts
IF the spec of the task's feature is in explained_artifacts: score += 2

// Trail already generated
IF the task's feature is in trails_generated: score += 1
```

**Complexity inference:** if the task does not explicitly declare complexity, estimate it based on the number of acceptance criteria listed:

- 1–2 criteria: `low`
- 3–4 criteria: `medium`
- 5+: `high`

**Tiebreaker:** in case of a score tie, select the task with the lowest index (order in `tasks.md`).

### Step 4 — Generate the briefing

With the selected task, generate the briefing:

```text
✦ mentor — suggested next task

  [task-id] · [title]  [features/<feature>]
  ──────────────────────────────────────────
  What to do: [plain-language description of what the task requires]

  Read before starting:
    [list of most relevant artifacts — file + section, if applicable]

  What you already know that's relevant:
    [items from the dev's history (completed tasks, read artifacts) that connect to this task]
    [if none: omit this section]

  Watch out for:
    [known risks: spec constraints, hook dependencies, relevant architectural decisions]
    [if no risks identified: omit this section]

  When done, run: /onboard badge
```

**Level calibration:**

- `junior`: "What to do" in plain language with analogy if needed. "Read before starting" lists more artifacts. "Watch out for" explains the risk in a didactic way.
- `mid`: direct technical language. Focuses on what is non-obvious.
- `senior`: 1–2 line summary per section. Omits anything trivial.

### Step 5 — Tracker integration (if installed)

Check `.speckit/extensions.json` for `jira` or `azure-devops` extensions.

**If `jira` is installed:**

1. Look up the Jira issue linked to the suggested task. The link is declared in the task metadata as `jira: <issue-key>` (e.g., `jira: AUTH-42`) or inferred from the task title.
2. If a linked issue is found, append to the briefing:

```text
  Jira: [issue-key] — [issue summary]
  Status: [jira status]  |  Assignee: [assignee or "unassigned"]
  → [issue URL]
```

1. If the task has no linked issue, append: `Jira: no linked issue found for this task.`
1. If the Jira extension cannot be reached, append: `Jira: integration unavailable.` and continue.

**If `azure-devops` is installed:**

1. Look up the Azure DevOps work item linked to the suggested task. The link is declared in the task metadata as `ado: <item-id>` (e.g., `ado: 1234`) or inferred from the task title.
2. If a linked item is found, append to the briefing:

```text
  Azure DevOps: [item-id] — [item title]
  State: [state]  |  Assigned to: [assignee or "unassigned"]
  → [item URL]
```

1. If the task has no linked item, append: `Azure DevOps: no linked work item found for this task.`
1. If the extension cannot be reached, append: `Azure DevOps: integration unavailable.` and continue.

**If neither is installed:** skip this step entirely.

### Step 6 — Closing question

Always end with:

```text
Would you like me to expand on any aspect before you start?
```

### Step 6 — Update the profile

Update `.onboard/profile.json`:

1. Increment `mentor_suggestions_followed` by 1.
2. Increment `consecutive_mentor_follows` by 1.
   - **Note:** `consecutive_mentor_follows` should only be incremented when the dev actually implements the suggested task. Since this command cannot know that, increment the counter here and let the `after-implement` hook check whether the completed task matches the last mentor suggestion.
   - For this, also store the suggested task ID in the profile (field `last_mentor_suggestion`: `"feature/task-id"`).
3. **Badge `mentor-streak`:** if `consecutive_mentor_follows >= 3`, move `"mentor-streak"` from `locked` to `earned`.
4. Update `last_updated`.

If `mentor-streak` was unlocked:

```text
🏅 Badge unlocked: mentor-streak — Followed the mentor 3 times in a row!
```

---

## Principles to follow

1. **Never suggest a blocked task.** Checking dependencies is mandatory before any suggestion.
2. **The briefing must be actionable.** The dev should be able to start immediately after reading the output.
3. **Vary suggestions based on history.** The scoring algorithm guarantees this — do not repeat the same task if it was previously suggested but not completed.
4. **End with an action.** The closing question is mandatory.
