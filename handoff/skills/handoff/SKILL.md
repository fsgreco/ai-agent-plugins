---
name: handoff
description: Persist durable session knowledge as markdown files in ~/Desktop/handoffs/ (indexed by QMD as the "ai-agents-handoffs" collection, read by future agents as long-term memory). Use whenever the user says "handoff", "save a handoff", "note this for future sessions", "instructions for other agents", or sends a bare /handoff. Also use to update an existing handoff by name or topic.
---

# Handoff

Handoffs are long-term memory for future agents in any session, not a status log. Run `mkdir -p ~/Desktop/handoffs` first.

## 1. If the user names an existing handoff file or topic → update

List `~/Desktop/handoffs/`, find the matching file (if qmd mcp or cli is available use it), read it, and propose edits to that file. Never create a duplicate. Refresh the "as of" date.

## 2. Otherwise → infer from the session

Collect only what a future agent needs.

Include:
- Verified facts with evidence: file paths and line numbers, API shapes, cause-effect chains, conventions, command results
- Decisions and rationale, including rejected alternatives and why
- Caveats and traps found during investigation
- Unfinished work: open questions, who owes an answer, proposed next steps
- Explicit instructions for future agents ("do not X", "prefer Y")

Exclude (stale as soon as someone replies or pushes):
- CI, label, and review-count snapshots
- Message-drafting iterations and conversation ping-pong
- Claims that were refuted during the session

## 3. Always confirm before writing

Show the proposed file name and full content. Ask the user to confirm, edit, or skip. Write only after confirmation.

## File conventions

- Kebab-case name, prefixed with the Jira/bug/PR ID or topic when applicable, e.g. `OCPBUGS-80938-pr-17347-review.md`, `secrets-migration-lessons.md`
- H1 title with the topic, then a `Status:` line with `as of YYYY-MM-DD` so staleness is detectable
- Plain markdown with clear section headers, one topic per file, no raw logs or dumps
- Mark unverified assumptions as assumptions
