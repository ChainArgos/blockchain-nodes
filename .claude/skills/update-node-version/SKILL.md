---
name: update-node-version
description: Use when the user provides a GitHub release URL for a blockchain node and wants to bump the version in this repo. Extracts version, updates docker-<pkg>/build.toml, runs sync-config.rs if present, and opens a PR after user confirmation.
---

# update-node-version

This skill is a thin wrapper. The full workflow lives in the repo root at [`NODE_UPDATES.md`](../../../NODE_UPDATES.md) so Codex, Amp, and any other agent that reads `AGENTS.md` can follow the same procedure.

**Read `NODE_UPDATES.md` and follow its workflow exactly.** The mapping table is at `.node-updates/mappings.toml`.

Use the Claude-specific commit trailer from [`COMMITS.md`](../../../COMMITS.md):

```text
Co-authored-by: Claude <noreply@anthropic.com>
```
