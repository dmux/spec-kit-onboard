# Command: /onboard badge

## Syntax

```bash
/onboard badge [--list] [--reset]
```

## Parameters

- `--list`: display the full badge catalog with criteria and status
- `--reset`: reset the developer profile (requires confirmation)
- No parameters: display earned badges and progress toward the next ones

---

## Agent instructions

You are executing the `/onboard badge` command of the spec-kit-onboard extension.

### Full badge catalog

| Badge ID | Display name | Criterion |
| --- | --- | --- |
| `first-read` | First read | Ran `/onboard explain` for the first time |
| `map-reader` | Map reader | Generated the first trail with `/onboard trail` |
| `navigator` | Navigator | Scored 5/5 on the quiz |
| `first-task` | First delivery | Completed the first task (via the after-implement hook) |
| `clean-pass` | Clean code | Completed a task with no cleanup issues (requires `cleanup` extension) |
| `spec-aware` | Spec-conscious | Explained all specs of a feature before implementing any task in it |
| `full-trail` | Full mapper | Generated a trail for all features with open tasks |
| `mentor-streak` | Guided streak | Followed the mentor's suggestion in 3 consecutive cycles |
| `autonomous` | Autonomous | Completed an entire feature without using `/onboard explain` during it |

---

## Behavior with no parameters

### Step 1 — Read the profile

Read `.onboard/profile.json`.

If it does not exist: respond "Profile not found. Run `/onboard start` to begin your onboarding."

### Step 2 — Calculate partial progress

For badges still in `locked`, calculate visible partial progress:

- **`spec-aware`**: count how many specs of each feature have been explained vs. total specs in the feature. Show the feature with the most progress.
- **`full-trail`**: count how many open features have a generated trail vs. total features with open tasks.
- **`mentor-streak`**: show current `consecutive_mentor_follows` vs. 3 required.
- **`navigator`**: show the best quiz score obtained so far, if any.

### Step 3 — Display

```text
✦ badges — [developer name]

  Earned ([N earned]/9)
  [for each badge in earned:]
  ✓ [badge-id]      [brief criterion description]

  Next up
  [for each badge in locked, from closest to furthest:]
  ○ [badge-id]      [brief criterion description]
    [if partial progress exists:]
    └─ progress: [current state]
```

If all 9 badges have been earned:

```text
✦ badges — [name] — Full collection! 🏆

  You've earned all 9 available badges in the catalog.
```

---

## Behavior with `--list`

Display the full catalog:

```text
✦ badges — full catalog

  [for each badge in the catalog:]
  [✓ or ○] [badge-id]
            Criterion: [full criterion description]
            [if earned:] Earned on: [date, if available in profile — omit otherwise]
```

---

## Behavior with `--reset`

1. Display:

```text
⚠ This will permanently delete your profile at .onboard/profile.json.
  All progress history, badges, and quiz records will be lost.

  Type "confirm" to proceed or anything else to cancel:
```

1. Wait for the user's response.

2. If the response is exactly `"confirm"` (case-insensitive):
   - Delete `.onboard/profile.json`
   - Display: "Profile reset. Run `/onboard start` to begin again."

3. If any other response:
   - Display: "Reset cancelled. Profile preserved."

---

## Principles to follow

1. **Never modify badges manually.** Badge calculation is the responsibility of the other commands and the hook. This command only reads and displays.
2. **`--reset` requires explicit confirmation.** Never delete the profile without the word "confirm" from the user.
3. **Be concise.** Output is formatted for the terminal.
