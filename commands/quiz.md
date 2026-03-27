# Command: /onboard quiz

## Syntax

```bash
/onboard quiz [--feature <name>] [--topic <spec|workflow|architecture>]
```

## Parameters

- `--feature`: restrict the quiz to a specific feature (default: all open features)
- `--topic`: thematic area — `spec`, `workflow`, `architecture` (default: mixed)

---

## Agent instructions

You are executing the `/onboard quiz` command of the spec-kit-onboard extension. Follow the steps below.

### Step 1 — Read context

1. Read `.onboard/profile.json`. If it does not exist, create it with default values.
2. Read project artifacts relevant to the quiz scope:
   - If `--feature` was provided: read `features/<feature>/spec.md` and `features/<feature>/tasks.md`
   - Otherwise: read spec.md and tasks.md of features with open tasks (maximum 3 features)
   - Read `.speckit/extensions.json`
3. Note `quiz_history` to avoid repeating questions from previous sessions.

### Step 2 — Generate the 5 questions

Generate exactly 5 questions. **Absolute rules:**

**Rule 1 — No generic questions.**
Every question MUST reference a specific artifact from the project: file name, task ID, feature name, spec line, installed extension name. Questions like "What is a spec?" are forbidden. Instead: "What is the main acceptance criterion for task T-003 in features/auth/tasks.md?"

**Rule 2 — Distribution of types.**
Distribute the 5 questions among the 3 types below. Do not use more than 3 questions of the same type:

- **Verifiable fact** (2–3 questions): the answer is explicitly in an artifact. E.g., "Which extension validates the spec before implementation?"
- **Simple inference** (1–2 questions): the answer requires reading two artifacts. E.g., "If T-004 depends on T-003 and T-003 is still open, what is the status of T-004?"
- **Practical consequence** (1 question): the answer requires understanding the impact of a decision. E.g., "If you change features/users/spec.md, which other spec would need to be reviewed and why?"

**Rule 3 — No repetition.**
Check `quiz_history` in the profile. If a question covers the same artifact and topic as a previous question, replace it with another.

**Rule 4 — Level calibration.**

- `junior`: verifiable fact questions predominate; multiple choice with 4 options
- `mid`: balanced mix; accepts short open answers in addition to multiple choice
- `senior`: inference and consequence questions predominate; open answers

**Multiple choice format:**

```text
(a) [option]  (b) [option]  (c) [option]  (d) [option]
```

Always include one correct option and three plausible distractors based on the real artifacts.

### Step 3 — Interactive presentation

Display the header:

```text
✦ quiz — 5 questions about the project
```

For each question (one at a time):

```text
  Question N/5
  ─────────────────────────────────────────
  [question text]

  [options, if multiple choice]

  Your answer:
```

Wait for the user's response.

After each response, provide immediate feedback:

**If correct:**

```text
  ✓ Correct. [1-line explanation with artifact reference: file + line/section if possible]
```

**If incorrect:**

```text
  ✗ Incorrect. The correct answer is [answer].
    [2–3 line explanation referencing the exact artifact]
    → /onboard explain [relevant artifact] to learn more.
```

### Step 4 — Final result

After the 5th question:

```text
✦ result — [score]/5

  [list of questions with ✓ or ✗ and the topic of each]

  [contextual message based on score]
```

**Messages by score range:**

- 5/5: "Perfect score! You have a solid grasp of the project."
- 3–4/5: "Good result. Review the items marked with ✗."
- 0–2/5: "I recommend reviewing the topics below before implementing:"

If score < 3, list: `→ /onboard explain [gap artifact]` for each wrong answer.

### Step 5 — Update the profile

Update `.onboard/profile.json`:

1. Add an entry to `quiz_history[]`:

```json
{
  "date": "[ISO8601]",
  "score": N,
  "total": 5,
  "gaps": ["[topic/artifact of each wrong answer]"]
}
```

1. Update `last_updated`.
2. **Badge `navigator`:** if score == 5, move `"navigator"` from `locked` to `earned` (if not already earned).

If `navigator` was unlocked:

```text
🏅 Badge unlocked: navigator — Perfect quiz score!
```

---

## Principles to follow

1. **Never invent answers.** If an artifact could not be read, do not generate questions about it.
2. **Feedback always references the artifact.** Every correction must cite the file (and line, if possible) where the correct answer is found.
3. **One question at a time.** Never display all questions at once — wait for each response.
4. **End with an action.** At the end, always suggest the next step: `/onboard mentor` or `/onboard explain <gap>`.
