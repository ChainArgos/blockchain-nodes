# update-node-version

A project-local Claude skill that turns a GitHub release URL for a blockchain node into a pull request bumping the matching `docker-<pkg>/build.toml` in this repo. Runs the chain's `sync-config.rs` (if present) to refresh `config/` files, pauses for explicit human confirmation, then commits and opens a PR. Never merges — stops at PR URL.

## Usage

Paste a GitHub release URL in chat, e.g.:

> update bsc to https://github.com/bnb-chain/bsc/releases/tag/v1.7.3

Claude discovers this skill via its frontmatter description and runs the workflow in `SKILL.md`.

## Adding a new mapping

When the skill errors with "No mapping for `<org>/<repo>`", append an entry to `mappings.toml`:

```toml
[[mapping]]
repo = "<org>/<repo>"           # from the release URL
tag_prefix = ""                 # e.g., "op-node/" for optimism monorepo, "celo-" for celo tags
docker_dir = "docker-<name>"    # target directory in the repo root
package = "<name>"              # must match [package].name in build.toml
```

Then re-run the skill. Commit the `mappings.toml` change as a normal `chore` commit.

## Files

- `SKILL.md` — Claude-facing instructions (the workflow).
- `mappings.toml` — seeded repo → docker-dir table.
- `README.md` — this file.
