---
name: landpr
description: Land an OpenClaw PR end-to-end using the repo landpr checklist. Use when someone requests “/landpr” or asks to merge/land a PR.
user-invocable: true
---

# Land PR (OpenClaw)

Use this skill to land **openclaw/openclaw** PRs only.

## Safety + Scope

- **Repo restriction:** only `openclaw/openclaw`. If the PR is in any other repo, stop and ask.
- **Confirmation required:** before rebase/force-push/merge, summarize the plan and ask for explicit approval.
- **Never close PRs.** PR must end in GitHub state **MERGED**.
- **No GitHub comments** unless the user explicitly approves (global policy).

## Instructions

Follow the checklist here:
- `/var/lib/clawd/repos/clawdinators/scripts/landpr.md`

If the user did not specify a PR, use the most recent PR mentioned in the conversation. If ambiguous, ask.

When ready to execute the merge step, confirm which strategy to use (rebase vs squash). If unclear, ask.

After completion, verify PR state == MERGED.
