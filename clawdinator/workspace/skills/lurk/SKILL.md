---
name: lurk
description: Monitor Discord channel activity and persist notable items to memory. Run from main session during heartbeat.
---

# Lurk Skill

Monitor Discord lurk channels and persist notable activity to shared memory.

## When to Use

- Hourly heartbeat (step 3)
- Manual trigger to capture current channel state

## How to Run

Use `discord.readMessages` to read recent messages from each lurk channel:
- #help (1456457255208878100) — support fires
- #general (1456350065223270435) — community pulse
- #clawdributors (1458141495701012561) — contributor coordination
- #messaging-infra (1458052766831480996) — transport integrations
- #nix-packaging (1457003026412736537) — nix reproducibility
- #architecture (1457810851556888833) — architecture talk
- #clawdhub (1457886486044213411) — hub activity
- #models (1456704705219661980) — model discussions
- #skills (1456891440897724637) — skill showcases
- #showcase (1456609488202105005) — user showcases
- #security (1458861780976795782) — security discussion

## What to Capture

**Persist these:**
- Support issues / bug reports
- Questions that indicate user confusion
- Feature requests with discussion
- Anything referencing GitHub issues/PRs
- Repeated topics (multiple users, same issue)
- Announcements or important updates

**Skip these:**
- Casual chat / banter
- Single-word reactions
- Bot spam
- Already-resolved questions

## Output

Append to `/memory/discord/YYYY-MM-DD.md`:

```markdown
## HH:MM #channel-name
- [brief summary of notable item]
- Links to #NNN if references GitHub issue
- @username if relevant

## HH:MM #channel-name
- [another item]
```

## Constraints

- Be selective. Only notable items.
- Include timestamp and channel name.
- Keep each entry to 1-2 lines.
- Cross-reference GitHub issues when mentioned.
- If nothing notable: don't write anything, reply HEARTBEAT_OK.
