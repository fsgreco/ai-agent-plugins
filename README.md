# ai-agent-plugins

Productivity plugins for developers who use AI coding agents in their daily workflow. Useful for small but repetitive tasks.

## Cross-agent portability

The plugins in this repo are currently built as **Claude Code skills** (markdown-based instructions with shell hooks).  
However, the core logic is written in plain natural language and shell scripts. The agent-specific metadata is a thin adapter layer.

The long-term goal is cross-agent portability: same plugins, different harnesses.  
Currently supported: **Claude Code** and **OpenCode**.

## Available plugins

### wt

Create and locate git worktrees for GitHub PRs and branches.

- `create-worktree.sh 14243`: worktree for a PR, branch named after the issue key in its title
- `create-worktree.sh OCPBUGS-9999`: worktree for a branch, created from where you launch it
- `clone-bare.sh user:repo`: one-time setup, bare clone in a container dir, fork wiring, default branch worktree

The scripts are the interface. Agents invoke them through the `wt` skill;
Users can manually use them too.

Idempotent: re-running a command returns the existing worktree instead of
creating a duplicate. Works from normal checkouts and bare-clone containers
(`console/.bare` + worktrees as siblings). Requires `git`; PR mode and fork
wiring require an authenticated [gh](https://cli.github.com/) CLI.

### scrum

Log daily standup entries from conversation context or direct text.  
This is a lightweight skill that creates a log into `~/Desktop/scrum/YYYY-MM-DD.md` automatically.

Three modes:  

- **Infer**: bare `/scrum` reads conversation context, suggests a one-line entry, and asks you to confirm before logging
- **Direct log**: `/scrum fixed login bug on PR #42` appends the entry immediately
- **List**: `/scrum list` shows today's entries

What it automates:

| Without skill | With skill |
|---------------|------------|
| "Where should I save this?" | `~/Desktop/scrum/YYYY-MM-DD.md` - automatic |
| Create directory, pick file name | Directory and today's file created at skill load |
| Decide on entry format | Always `- <text>`, consistent |
| 4-5 tool calls to log an entry | 2 tool calls (Read + Edit) |
| No context inference | Suggests entries from what you've been working on |

## Installation

### OpenCode

Add the catalog URL to the `skills` array in your `opencode.json`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": [
    "https://raw.githubusercontent.com/fsgreco/ai-agent-plugins/main/wt/skills/"
  ]
}
```

Each plugin serves its own catalog from its `skills/` directory, so add one
URL per plugin you want. Skills are downloaded and cached; they refresh
automatically when the catalog's `version` in the plugin's `index.json` is
bumped. To run unreleased changes, clone this repo and point `skills` at the
clone path instead.

### Claude Code

#### 1. Add the marketplace

```
/plugin marketplace add fsgreco/ai-agent-plugins
```

#### 2. Install a plugin

```
/plugin install scrum@ai-agent-plugins
```

#### 3. Reload and use

```
/reload-plugins
/scrum                          # infer entry from conversation context
/scrum fixed login bug on PR #42  # log directly
/scrum list                     # show today's entries
```

## License

MIT
