# AGENTS.md

This repository uses `main` as its primary branch. This file is the canonical home for rules and restrictions that apply only to AI agents. Rules that apply equally to human contributors and agents live in topic-specific files linked under **Shared conventions** below.

## Pull Request Merging (agent-only)

**Agents must never merge a pull request without explicit per-PR confirmation from the human operator.**

- Open the PR, share the URL, and stop. The default response after creating a PR is "PR URL — ready for your review" — not a merge command in the same turn.
- Prior "just do it" / "don't wait for me" / "proceed autonomously" authorizations apply only to the specific workstream the operator was discussing when they issued them. They do not carry forward to later PRs in the same session or to new sessions. Treat each PR as a fresh approval gate.
- `--admin` / branch-protection bypass is a privilege, not a default. Use it only when the operator explicitly authorizes merging *this specific PR*.
- Phrasing that does NOT authorize merge (ask anyway): "proceed", "don't wait for me", "looks good". Phrasing that does: "merge it", "merge this one", "you can merge now", "ship it".
- Bounded authorization: if the operator says "merge all the PRs we just discussed", merge only the named set — not unrelated PRs that exist or that you open later.

If you are uncertain whether authorization applies to the PR in front of you, ask. The cost of pausing is ~30 seconds; the cost of merging something the operator wasn't ready for is much higher.

## Commit Attribution (agent-only)

Every commit created by an AI agent in this repository must include **exactly one** `Co-authored-by` trailer identifying the agent that made the commit. The trailer identifies the **agent tool**, not the underlying model — never stack multiple agent trailers on one commit.

For Claude Code:

```text
Co-authored-by: Claude <noreply@anthropic.com>
```

See [COMMITS.md](COMMITS.md) for the trailer rules and the repo's commit-message format.

## CLI option ordering (shared)

Keep CLI arguments, flags, and similar option lists sorted consistently whenever order does not affect behavior. This applies to node launcher scripts and comparable config sections so differences between nodes stay easy to scan and compare. Do not reorder positional arguments, subcommands, or any options whose order is semantically significant.

## Shared conventions

Rules in the files below apply to everyone working in the repo — human and agent:

- [RULES.md](RULES.md) — documentation-location convention (no project rules in tool-specific files).
- [BRANCHING.md](BRANCHING.md) — branch naming, feature-branch policy, what never to commit to `main`.
- [COMMITS.md](COMMITS.md) — Conventional Commits format and agent-attribution trailer.
- [BUILD_SYSTEM.md](BUILD_SYSTEM.md) — Rust-based Docker build system: `build.toml` schema, `just build <pkg>`, tag formats.
