---
name: update-node-version
description: Use when the user provides a GitHub release URL for a blockchain node and wants to bump the version in this repo. Extracts version, updates docker-<pkg>/build.toml, treats sync-config.rs output as advisory, and opens a PR after user confirmation.
---

# update-node-version

Bump a packaged blockchain node to a new upstream release. The full workflow — URL parsing, mapping lookup, `build.toml` edit, sync-config reconciliation, human gate, branch/commit/PR — lives in [`NODE_UPDATES.md`](../../../NODE_UPDATES.md).

**Read `NODE_UPDATES.md` and follow its workflow exactly.** The human-gate and no-auto-merge rules there are mandatory.

## Gotchas

- The release URL must match an entry in `.node-updates/mappings.toml`. If it does not, the workflow directs you to add one — do not guess the `docker_dir` or `package`.
- For packages with `sync-config.rs`, consult `.node-updates/approved-config-overrides/<package>.toml` before treating a config diff as already approved. Do not accept unchecked local values as automatically approved.
- `sync-config.rs` output is upstream reference material, not repo content to be applied blindly.
