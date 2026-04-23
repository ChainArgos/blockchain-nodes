# update-node-version

A Claude Code discovery entry point for the node-version-update workflow. The workflow itself lives at [`NODE_UPDATES.md`](../../../NODE_UPDATES.md) in the repo root so Codex, Amp, and any other agent that reads `AGENTS.md` can follow the same procedure without duplicating instructions.

## Usage

Paste a GitHub release URL in chat, e.g.:

> update bsc to https://github.com/bnb-chain/bsc/releases/tag/v1.7.3

Claude picks up this skill via its frontmatter description and jumps to `NODE_UPDATES.md`. Codex and Amp users should read `NODE_UPDATES.md` directly (it is linked from `AGENTS.md`).

## Config correctness

For packages that ship a `sync-config.rs`, use `.node-updates/approved-config-overrides/<package>.toml` as the source of truth for already-reviewed local differences. The sync script is there to surface upstream drift, not to blindly replace local operator-curated values.

When the sync output differs from the repo:

- If a diff matches an approved override record exactly, restore the approved local value without flagging it as new.
- If upstream adds new options, sections, or files, stop and ask the user how they want to handle them.
- If upstream changes a key that already has an approved override but the upstream side no longer matches the recorded reviewed value, stop and ask what to do.
- If no approved override exists for a changed key, stop and ask the user to review it case by case.

After the user confirms a local override, record it in `.node-updates/approved-config-overrides/<package>.toml` so later updates only flag genuinely new drift.

## Adding a new mapping

When the workflow errors with "No mapping for `<org>/<repo>`", append an entry to `.node-updates/mappings.toml` at the repo root:

```toml
[[mapping]]
repo = "<org>/<repo>"           # from the release URL
tag_prefix = ""                 # e.g., "op-node/" for optimism monorepo, "celo-" for celo tags
docker_dir = "docker-<name>"    # target directory in the repo root
package = "<name>"              # must match [package].name in build.toml
```

Then re-run the workflow. Commit the `mappings.toml` change as a normal `chore` commit.

## Files

- `SKILL.md` — Claude Code discovery shim that points at `NODE_UPDATES.md`.
- `README.md` — this file.

The workflow and mapping data live outside this directory so they are agent-neutral.
