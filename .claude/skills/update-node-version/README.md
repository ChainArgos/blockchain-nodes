# update-node-version

A Claude Code discovery entry point for the node-version-update workflow. The workflow itself lives at [`NODE_UPDATES.md`](../../../NODE_UPDATES.md) in the repo root so Codex, Amp, and any other agent that reads `AGENTS.md` can follow the same procedure without duplicating instructions.

## Usage

Paste a GitHub release URL in chat, e.g.:

> update bsc to https://github.com/bnb-chain/bsc/releases/tag/v1.7.3

Claude picks up this skill via its frontmatter description and jumps to `NODE_UPDATES.md`. Codex and Amp users should read `NODE_UPDATES.md` directly (it is linked from `AGENTS.md`).

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
