---
name: update-node-version
description: Use when the user provides a GitHub release URL for a blockchain node and wants to bump the version in this repo. Extracts version, updates docker-<pkg>/build.toml, treats sync-config.rs output as advisory, and opens a PR after user confirmation.
---

# update-node-version

This skill is a thin wrapper. The full workflow lives in the repo root at [`NODE_UPDATES.md`](../../../NODE_UPDATES.md) so Codex, Amp, and any other agent that reads `AGENTS.md` can follow the same procedure.

**Read `NODE_UPDATES.md` and follow its workflow exactly.** The mapping table is at `.node-updates/mappings.toml`.

Important: for packages with `sync-config.rs`, existing checked-in config values are canonical. Never overwrite them automatically; use sync output only to detect upstream changes that need user review.

Use the commit trailer that matches the current agent, as documented in [`COMMITS.md`](../../../COMMITS.md) and [`AGENTS.md`](../../../AGENTS.md):

```text
Co-authored-by: <current-agent> <agent-email>
```
