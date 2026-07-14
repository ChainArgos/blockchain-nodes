# Rules

## Documentation Convention

All project rules, conventions, commands, and architecture info must live in this repo's topic-specific rule files (linked from [AGENTS.md](AGENTS.md)) — never in tool-specific config files (e.g., `CLAUDE.md`, `GEMINI.md`, `COPILOT.md`).

Tool-specific instruction files (e.g., `CLAUDE.md`) must be **symlinks to `AGENTS.md`** so every agent reading either filename receives identical content:

```bash
ln -s AGENTS.md CLAUDE.md
```

This is preferred over a one-line `@AGENTS.md` import because Grok and OpenCode do not resolve `@`-imports and would otherwise see literal `@AGENTS.md` text. On Windows checkouts without symlink support (needs Developer Mode or `git config core.symlinks true`), fall back to a `CLAUDE.md` containing only `@AGENTS.md`.

This ensures instructions are shared across all AI agents regardless of which tool is used.