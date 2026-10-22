---
name: scrum
description: Log daily standup entries to ~/Desktop/scrum/. Supports inference mode (suggests an entry based on conversation context), direct logging, and listing today's entries.
license: MIT
compatibility: opencode
---

# Scrum Daily Log

First, ensure the scrum directory and today's file exist by running:

```bash
mkdir -p ~/Desktop/scrum && touch ~/Desktop/scrum/$(date +%Y-%m-%d).md
```

Today's log file is `~/Desktop/scrum/<today's date in YYYY-MM-DD>.md`.

## 1. If the user says "list" → read only

Read today's log file. If it doesn't exist or is empty, say "No entries for today." Done.

## 2. If the user provides text to log → direct log

Append `- <text>` to today's log file. Confirm with the entry added. Done.

## 3. If no specific text is provided → infer from context

1. Look at the current conversation context.
2. Suggest a one-line summary of the work done — under 100 characters, focusing on what was done and which artifact (PR, file, ticket).
3. Ask the user to confirm, edit, or skip the suggested entry.
4. If confirmed, append `- <confirmed text>` to today's log file.

## Example entries

```
- reviewed PR #16555, suggested null safety fix in isConditionFailing
- migrated cluster-settings cypress test to playwright
- triaged CI failures on PR #16420, all unrelated
```
