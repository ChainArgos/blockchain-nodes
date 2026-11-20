# Skills

Agent-neutral convention for shipping **agent skills inside this repo** (committable, team-shared — not installable plugins, not host-global) so they work across Claude Code, Codex, OpenCode, Amp, Grok Build, Muse Code, and Antigravity.

This follows the open [Agent Skills specification](https://agentskills.io/specification) and its [client-integration guide](https://agentskills.io/client-implementation/adding-skills-support). Agent-only rules live in [AGENTS.md](AGENTS.md); the documentation-location rule lives in [RULES.md](RULES.md).

## The problem: no single directory is read by all seven

Project-scope discovery (verified per vendor docs):

| Agent | `.claude/skills/<name>/` | `.agents/skills/<name>/` |
|---|---|---|
| Claude Code | native — the **only** path it reads | — |
| OpenCode | native | native |
| Amp | native | native |
| Grok Build | native (Claude-Code compatibility) | global `~/.agents/` only, not project |
| Codex | — | native — the **only** path it reads |

`.claude/skills/` misses Codex and Antigravity. `.agents/skills/` misses Claude and Grok-project. **No single directory reaches all seven**, so a link is unavoidable if we want zero duplication.

Two more clients (researched Nov 2026 — see links under each row):

| Agent | Project skill dirs scanned | Notes |
|---|---|---|
| Muse Code ([skills doc](https://meta-models.github.io/muse-code-sdk/next/guides/extend/skills/), [extending doc](https://dev.meta.ai/docs/muse-code/extending)) | `.agents/skills/` (recommended) **plus** `.codex/skills/` and `.claude/skills/` ("always scanned") | Any one of the three roots suffices. Symlink handling for project skill dirs is undocumented; only plugin packages are documented to refuse symlinks. |
| Antigravity ([skills doc](https://antigravity.google/docs/skills/), [discovery doc](https://antigravity.google/docs/customization-discovery/)) | `.agents/skills/` (canonical; also reads `.agents/` in each parent folder up to the repo root; legacy `.agent/skills/` still works) | `.claude/skills/` is **not** scanned by default (reachable only via user-configured `skills.json` manifests / Skill Custom Paths). Community reports (not vendor docs) claim symlinked skill dirs are silently ignored — treat as unverified, but prefer a real dir here regardless. |

Antigravity explicitly endorses the [open Agent Skills standard](https://agentskills.io/home); Muse aligns implicitly (its `skills validate` reports an `agent-skills-common-subset` compatibility profile; no explicit agentskills.io endorsement found).

## Solution: one real file + one symlink

The spec is [silent on placement](https://agentskills.io/client-implementation/adding-skills-support) — it defines only what goes *inside* a skill dir. The integration guide names `.agents/skills/` the cross-client convention and notes `.claude/skills/` is read "for pragmatic compatibility" by most clients.

We keep the **real** skill under `.agents/skills/` — native for Codex, Antigravity, OpenCode, and Amp; recommended for Muse Code; the convention path — and add a **relative symlink** under `.claude/skills/` so Claude Code (and Grok, via Claude compatibility) reach the same file:

```
.agents/skills/<name>/SKILL.md                        # the only real copy
.claude/skills/<name>  ->  ../../.agents/skills/<name>  # symlink for Claude Code / Grok
```

Claude Code [follows symlinked skill directories](https://docs.claude.com/en/docs/claude-code/skills) (confirmed). The symlink matters **only for Claude Code and Grok** (undocumented for Grok — see residual risk below); every other client reads the real dir natively. This direction is strictly safer than the reverse: it depends on symlink-following only for Claude (confirmed), never for Antigravity (community-reported to ignore symlinks) or Codex.

### Residual risk (honest unknowns)

- Grok reads `.claude/skills/` at project scope, which is now a symlink — Grok symlink-following is undocumented. If Grok ever fails to load the skill, the fix is client-side (a real dir) or Grok-side (follow symlinks like Claude).
- Muse Code and Antigravity symlink handling for project skill dirs is likewise undocumented — but irrelevant here, since both read the real `.agents/skills/` dir natively.

### Why not copy — and why no include directive?

- **Copying** the skill into both directories means two files that drift. Rejected.
- **There is no portable `@include`/import directive** across these agents. `@path` composition is Amp/Claude-specific (documented for `AGENTS.md`, not `SKILL.md` bodies); OpenCode/Codex/Grok ignore it. A symlink — or a single canonical dir, which is impossible here — is the only zero-duplication mechanism. This is why we use a "sublink".

### Dedup / collision (same skill reachable via two roots)

| Agent | behavior |
|---|---|
| Claude Code | reads the `.claude/skills/` symlink (follows it — confirmed); dedups by target path — loads once |
| OpenCode | skill names must be unique; sees the real dir natively (the `.claude` symlink resolves to the same target — harmless) |
| Amp | first-wins by precedence (`user > .agents > .claude`) — real dir wins |
| Grok Build | reads `.claude/skills/` at project scope — currently a symlink (see residual risk) |
| Codex | reads only `.agents/skills/` — sees the real dir |
| Muse Code | scans `.agents`, `.codex`, and `.claude` roots — reaches the real dir; identical content via the symlink is harmless |
| Antigravity | reads the real `.agents/skills/` dir natively; the `.claude` symlink is irrelevant to it |

## SKILL.md frontmatter (intersection of all agents)

- `name` — required; must match the directory name; `^[a-z0-9]+(-[a-z0-9]+)*$`, ≤64 chars.
- `description` — required by all; ≤**1024 chars** (OpenCode cap; Claude allows 1536 — use 1024). Front-load trigger keywords: Codex truncates descriptions to fit ~2% of context.

Avoid Claude-only fields (`paths`, `allowed-tools`, `${CLAUDE_PROJECT_DIR}`, `` !`cmd` ``) in cross-agent skills — OpenCode/Codex/Grok treat them as inert literal text. Use plain repo-root-relative paths in prose.

## Progressive disclosure

Per the [spec](https://agentskills.io/specification): the catalog (`name`+`description`, ~50–100 tokens) loads at session start; the full `SKILL.md` body loads on activation (keep it **<500 lines / <5000 tokens**); bundled scripts/references load on demand. Keep skills small and delegate heavy content to a root doc.

## Authoring rules

1. **Thin wrapper over a root doc.** A skill points at a repo-root topic file (e.g. `NODE_UPDATES.md`) that holds the real workflow; it must not duplicate it. The skill is discovery UX, not the source of truth. This honors [RULES.md](RULES.md).
2. **No project rules in skill bodies.** Reference the canonical docs; do not restate repo rules.
3. **Bundled resources** (scripts, references) live next to `SKILL.md`; keep them one level deep.
4. **Relative paths** resolve against the skill directory (the parent of `SKILL.md`). Both `.claude/skills/<name>/` and `.agents/skills/<name>/` sit three levels below the repo root, so `../../../<root-doc>` resolves correctly through either path — re-verify after any move.
5. **Skill bodies are operational, not meta.** A `SKILL.md` body loads into context on activation, so every line costs tokens. Put placement/discovery details here in `SKILLS.md`, not in the skill. Follow the [skill-creation best practices](https://agentskills.io/skill-creation/best-practices): add what the agent lacks, omit what it knows, and surface non-obvious project-specific pitfalls in a `## Gotchas` section.

> The spec's "file references one level deep" guidance concerns **bundled skill resources** (scripts/assets shipped with the skill), not a pointer from a thin wrapper to a repo-root document. Pointing up to `NODE_UPDATES.md` is intentional: the workflow keeps one canonical home shared with `AGENTS.md` and human readers.

## Plugin vs in-repo skill

A **plugin** ([Codex](https://developers.openai.com/codex/build-plugins), [anthropics/skills](https://github.com/anthropics/skills)) is an installable, distributable package that may bundle multiple skills + MCP. An **in-repo skill** is a `SKILL.md` committed to the repo and discovered by scanning. Use in-repo skills for workflows tightly coupled to this repo (like `update-node-version`); reserve plugins for cross-repo distribution.

## Verifying discovery

| Agent | how to confirm the skill is loaded |
|---|---|
| Claude Code | auto-loads on `description` match |
| OpenCode | `skill` tool lists it |
| Codex (CLI/IDE) | `/skills`, or type `$` |
| Amp | command palette → `skill: list` |
| Grok Build | `grok inspect`, or `/skills` |
| Muse Code | `muse skills validate` passes (requires `description`); skills load from the scanned roots above |
| Antigravity | workspace `.agents/skills/` is scanned by default; extra roots via `skills.json` manifests or Settings → Skill Custom Paths |

## Current skills

- [`update-node-version`](.agents/skills/update-node-version/SKILL.md) — bump a node from a GitHub release URL; delegates to [NODE_UPDATES.md](NODE_UPDATES.md). Symlinked at `.claude/skills/update-node-version` for Claude Code (and Grok).
