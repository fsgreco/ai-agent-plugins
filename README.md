# ai-agent-plugins

Productivity plugins for developers who use AI coding agents in their daily workflow. Useful for small but repetitive tasks.

## Cross-agent portability

The plugins in this repo are currently built as **Claude Code skills** (markdown-based instructions with shell hooks).  
However, the core logic is written in plain natural language and shell scripts. The agent-specific metadata is a thin adapter layer.

The long-term goal is cross-agent portability: same plugins, different harnesses.  
As standards emerge for agent plugin distribution, these will be adapted to support them. For now, Claude Code is the primary target.

## Available plugins

### scrum

Log daily standup entries from conversation context or direct text.  
This is a lightweight skill that creates a log into `~/Desktop/scrum/YYYY-MM-DD.md` automatically.

Three modes:  

- **Infer** — bare `/scrum` reads conversation context, suggests a one-line entry, and asks you to confirm before logging
- **Direct log** — `/scrum fixed login bug on PR #42` appends the entry immediately
- **List** — `/scrum list` shows today's entries

What it automates:

| Without skill | With skill |
|---------------|------------|
| "Where should I save this?" | `~/Desktop/scrum/YYYY-MM-DD.md` - automatic |
| Create directory, pick file name | Directory and today's file created at skill load |
| Decide on entry format | Always `- <text>`, consistent |
| 4-5 tool calls to log an entry | 2 tool calls (Read + Edit) |
| No context inference | Suggests entries from what you've been working on |

## Installation

### 1. Add the marketplace

```
/plugin marketplace add fsgreco/ai-agent-plugins
```

### 2. Install a plugin

```
/plugin install scrum@ai-agent-plugins
```

### 3. Reload and use

```
/reload-plugins
/scrum                          # infer entry from conversation context
/scrum fixed login bug on PR #42  # log directly
/scrum list                     # show today's entries
```

## License

MIT
