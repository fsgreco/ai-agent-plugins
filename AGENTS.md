# AI Agent Plugins

## Project structure

This is a Claude Code plugin marketplace. Each top-level directory (except `.claude-plugin/`) is a plugin.

```
.claude-plugin/marketplace.json   ← marketplace catalog
<plugin-name>/
├── .claude-plugin/plugin.json    ← plugin manifest (name, version, description)
└── skills/<skill-name>/
    ├── SKILL.md                  ← skill instructions (markdown + frontmatter)
    └── scripts/                  ← shell scripts used by the skill
```

## Guidelines

- Skills are natural language instructions in markdown — keep them lean and imperative.
- Shell scripts go in `scripts/` and are invoked via `!` backtick syntax at skill load time. The `!` backtick does not support command substitution (`$(...)`) — use wrapper scripts for that.
- `allowed-tools` in SKILL.md frontmatter pre-authorizes tool patterns so the skill doesn't prompt for permission.
- `$ARGUMENTS` captures user input after the slash command. Route behavior based on its value.
- When adding a new plugin, update `.claude-plugin/marketplace.json` with a new entry.
- Bump `version` in the plugin's `plugin.json` when making changes.
