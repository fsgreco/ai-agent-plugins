# AI Agent Plugins

## Project structure

This is a Claude Code plugin marketplace. Each top-level directory (except `.claude-plugin/`) is a plugin.

```
.claude-plugin/marketplace.json   ← marketplace catalog
<plugin-name>/
├── .claude-plugin/plugin.json    ← plugin manifest (name, version, description)
└── skills/<skill-name>/
    ├── SKILL.md                  ← skill instructions (markdown + frontmatter)
    └── scripts/                  ← optional shell scripts used by the skill
```

## Guidelines

- Skills are natural language instructions in markdown — keep them lean and imperative.
- The canonical `skills/<name>/SKILL.md` is harness-agnostic: both Claude Code and OpenCode load the same file. Write the body in plain language ("append to the file", "ask the user to confirm") instead of harness-specific tool names.
- Inline trivial setup (mkdir, touch) as a plain bash block the agent runs on first use. Do not use `!` backtick load-time execution or `${CLAUDE_SKILL_DIR}`: those are Claude Code-only and break portability.
- `scripts/` is for logic complex enough to justify a real file (see `wt`). Instruct the agent to run scripts with plain `bash <path>` text, never `!` auto-execution.
- `allowed-tools` in SKILL.md frontmatter pre-authorizes tool patterns in Claude Code; other harnesses ignore it, so it is safe to keep.
- `when_to_use` frontmatter improves triggering; phrase it for any harness.
- Do not use `$ARGUMENTS` or other slash-command variables: route behavior on the user's phrasing instead ("if the user says 'list'").
- When adding a new plugin, update `.claude-plugin/marketplace.json` with a new entry.
- Bump `version` in the plugin's `plugin.json` when making changes.
