# Skills

Agent-neutral convention for shipping **agent skills inside this repo** (committable, team-shared — not installable plugins, not host-global) so they work across Claude Code, Codex, OpenCode, Amp, and Grok Build.

This follows the open [Agent Skills specification](https://agentskills.io/specification) and its [client-integration guide](https://agentskills.io/client-implementation/adding-skills-support). Agent-only rules live in [AGENTS.md](AGENTS.md); the documentation-location rule lives in [RULES.md](RULES.md).

## The problem: no single directory is read by all five

Project-scope discovery (verified per vendor docs):

| Agent | `.claude/skills/<name>/` | `.agents/skills/<name>/` |
|---|---|---|
| Claude Code | native — the **only** path it reads | — |
| OpenCode | native | native |
| Amp | native | native |
| Grok Build | native (Claude-Code compatibility) | global `~/.agents/` only, not project |
| Codex | — | native — the **only** path it reads |

`.claude/skills/` covers 4/5 (misses Codex). `.agents/skills/` covers 3/5 at project scope (misses Claude and Grok-project). **No single directory reaches all five**, so a link is unavoidable if we want zero duplication.

## Solution: one real file + one symlink

The spec is [silent on placement](https://agentskills.io/client-implementation/adding-skills-support) — it defines only what goes *inside* a skill dir. The integration guide names `.agents/skills/` the cross-client convention and notes `.claude/skills/` is read "for pragmatic compatibility" by most clients.

We keep the **real** skill under `.claude/skills/` — broadest native coverage (4/5, and the only path Claude Code reads) — and add a **relative symlink** under `.agents/skills/` so Codex reaches the same file:

```
.claude/skills/<name>/SKILL.md                        # the only real copy
.agents/skills/<name>  ->  ../../.claude/skills/<name>  # symlink for Codex
```

Both Claude Code ([docs](https://docs.claude.com/en/docs/claude-code/skills)) and Codex ([docs](https://developers.openai.com/codex/build-skills)) follow symlinked skill directories. The symlink matters **only for Codex**; the other four already read `.claude/skills/` natively. This direction is strictly safer than the reverse: it depends on symlink-following only for Codex (confirmed), never for Grok (undocumented).

### Why not copy — and why no include directive?

- **Copying** the skill into both directories means two files that drift. Rejected.
- **There is no portable `@include`/import directive** across these agents. `@path` composition is Amp/Claude-specific (documented for `AGENTS.md`, not `SKILL.md` bodies); OpenCode/Codex/Grok ignore it. A symlink — or a single canonical dir, which is impossible here — is the only zero-duplication mechanism. This is why we use a "sublink".

### Dedup / collision (same skill reachable via two roots)

| Agent | behavior |
|---|---|
| Claude Code | dedups by target path — loads once |
| OpenCode | skill names must be unique; a duplicate is shadowed (identical content via the symlink, so harmless) |
| Amp | first-wins by precedence (`user > .agents > .claude`) |
| Grok Build | reads only `.claude/skills/` at project scope — sees it once |
| Codex | reads only `.agents/skills/` — sees it once |

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

## Current skills

- [`update-node-version`](.claude/skills/update-node-version/SKILL.md) — bump a node from a GitHub release URL; delegates to [NODE_UPDATES.md](NODE_UPDATES.md). Symlinked at `.agents/skills/update-node-version` for Codex.
