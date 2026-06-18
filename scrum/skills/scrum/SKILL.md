---
name: scrum
description: Log daily standup entries to ~/Desktop/scrum/. Supports inference mode (suggests an entry based on conversation context), direct logging, and listing today's entries.
when_to_use: Use whenever the user says "log this", "scrum", "note for standup", "daily log", "what did I do today", "add that to my standup notes", "log what I just did", or wants to record or review work done for standup. Also trigger on bare /scrum with no arguments to infer an entry from conversation context.
allowed-tools:
  - Bash(echo * >> ~/Desktop/scrum/*)
---

# Scrum Daily Log

Arguments: $ARGUMENTS

!`bash ${CLAUDE_SKILL_DIR}/scripts/setup.sh`

Today's log file is `~/Desktop/scrum/`!`date +%Y-%m-%d``.md`

## 1. If `$ARGUMENTS` is "list" → read only

Read today's log file. If it doesn't exist or is empty, say "No entries for today." Done.

## 2. If `$ARGUMENTS` is non-empty text → direct log

Use the Edit tool to append `- $ARGUMENTS` to today's log file. Confirm with the entry added. Done.

## 3. If `$ARGUMENTS` is empty → infer from context

1. Look at the current conversation context.
2. Suggest a one-line summary of the work done — under 100 characters, focusing on what was done and which artifact (PR, file, ticket).
3. Use AskUserQuestion to let the user confirm, edit, or skip the suggested entry.
4. If confirmed, use the Edit tool to append `- <confirmed text>` to today's log file.

## Example entries

```
- reviewed PR #16555, suggested null safety fix in isConditionFailing
- migrated cluster-settings cypress test to playwright
- triaged CI failures on PR #16420, all unrelated
```
