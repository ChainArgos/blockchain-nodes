---
name: update-node-version
description: Use when the user provides a GitHub release URL for a blockchain node and wants to bump the version in this repo. Extracts version, updates docker-<pkg>/build.toml, treats sync-config.rs output as advisory, then commits and opens a PR automatically (never merges).
---

# update-node-version

Bump a packaged blockchain node to a new upstream release. The full workflow — URL parsing, mapping lookup, `build.toml` edit, sync-config reconciliation, branch/commit/PR — lives in [`NODE_UPDATES.md`](../../../NODE_UPDATES.md).

**Read `NODE_UPDATES.md` and follow its workflow exactly.** The no-auto-merge rule there is mandatory. The workflow commits and opens the PR without a separate confirmation step; genuine ambiguity (config drift outside approved overrides, a non-zero `sync-config.rs`, an existing branch) still triggers a STOP — see steps 4, 6, 7, and 9 of `NODE_UPDATES.md`.

## Gotchas

- The release URL must match an entry in `.node-updates/mappings.toml`. If it does not, the workflow directs you to add one — do not guess the `docker_dir` or `package`.
- For packages with `sync-config.rs`, consult `.node-updates/approved-config-overrides/<package>.toml` before treating a config diff as already approved. Do not accept unchecked local values as automatically approved.
- `sync-config.rs` output is upstream reference material, not repo content to be applied blindly.
