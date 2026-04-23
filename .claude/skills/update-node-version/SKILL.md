---
name: update-node-version
description: Use when the user provides a GitHub release URL for a blockchain node and wants to bump the version in this repo. Extracts version, updates docker-<pkg>/build.toml, runs sync-config.rs if present, and opens a PR after user confirmation.
---

# update-node-version

Given a GitHub release URL like `https://github.com/bnb-chain/bsc/releases/tag/v1.7.3`, bump the matching `docker-<pkg>/build.toml`, sync any chain config, and open a PR. Never merge — stop at PR URL.

## When to use

Invoke this skill when the user pastes (or clearly references) a GitHub release URL for a blockchain node tracked in this repo. Typical phrasings:
- "update bsc to https://github.com/bnb-chain/bsc/releases/tag/v1.7.3"
- "new bor release: https://github.com/0xPolygon/bor/releases/tag/v2.7.1"
- "bump geth https://github.com/ethereum/go-ethereum/releases/tag/v1.17.2"

If the URL does not match `https://github.com/<org>/<repo>/releases/tag/<tag>`, stop and ask the user for a release URL.

## Workflow

Follow these steps in order. Do not skip the human gate.

### 1. Parse the URL

Extract `org`, `repo`, and `tag` from the path. Examples:
- `https://github.com/bnb-chain/bsc/releases/tag/v1.7.3` → `org=bnb-chain`, `repo=bsc`, `tag=v1.7.3`
- `https://github.com/ethereum-optimism/optimism/releases/tag/op-node/v1.16.12` → `org=ethereum-optimism`, `repo=optimism`, `tag=op-node/v1.16.12`

### 2. Look up the mapping

Read `.claude/skills/update-node-version/mappings.toml`. Among entries where `repo == "<org>/<repo>"`, pick the one whose `tag_prefix` is the **longest** prefix of `tag`. An empty `tag_prefix` matches only when no longer prefix is available for the same repo.

If no entry matches, STOP and print:

```
No mapping for <org>/<repo>. Add an entry to .claude/skills/update-node-version/mappings.toml:

[[mapping]]
repo = "<org>/<repo>"
tag_prefix = "<prefix-or-empty-string>"
docker_dir = "docker-<name>"
package = "<name-from-build.toml>"
```

### 3. Derive the version

Take `tag`, strip the matched `tag_prefix` from the front, then strip a single leading `v` if present. Examples:
- `tag=v1.7.3`, `tag_prefix=""` → version `1.7.3`
- `tag=op-node/v1.16.12`, `tag_prefix="op-node/"` → version `1.16.12`
- `tag=celo-v2.2.2`, `tag_prefix="celo-"` → version `2.2.2`
- `tag=10.6.3`, `tag_prefix=""` → version `10.6.3`

### 4. Check current state

Read `<docker_dir>/build.toml`. If `[package].version` already equals the new version, STOP with "already at v<version>" — no changes, no branch, no commit.

### 5. Update `build.toml`

Edit `<docker_dir>/build.toml`:
- Set `[package].version = "<new-version>"`.
- If the `[package].build` field **currently exists**, set `[package].build = "1"`. If it does not exist, do not add it.
- If `<org>/<repo> == "ethereum/go-ethereum"` AND `[vars].git_commit` exists in `build.toml`: fetch `https://geth.ethereum.org/downloads`, regex the HTML for `geth-linux-amd64-<version>-([0-9a-f]{8})\.tar\.gz` where `<version>` is the resolved version, and update `[vars].git_commit` to the captured 8-char SHA. If the page fetch fails or the filename is not found, pause and ask the user to paste the 8-char commit SHA; use their response.

Do not touch any other fields in `build.toml`.

### 6. Run sync-config.rs (if present)

If `<docker_dir>/sync-config.rs` exists: run `./sync-config.rs` with the working directory set to `<docker_dir>`. If the script exits non-zero, STOP — print its output and tell the user the working tree is in a partial state; do not commit.

If `sync-config.rs` does not exist: skip silently.

### 7. Show the diff

Run `git status` and `git diff` and display the output to the user so they can review. Summarize what changed in one line (e.g., "Updated bsc-geth from v1.7.2 to v1.7.3; refreshed config/config.toml and config/genesis.json.").

### 8. HUMAN GATE — wait for confirmation

STOP and wait for the user to explicitly confirm. Acceptable confirmations: "yes", "proceed", "ship it", "looks good, commit it", "go ahead".

If the user declines or asks for changes, do not commit. Leave the edits on disk so they can adjust.

Do not commit just because the user says "looks good" without "commit" / "proceed" / "ship" — if it's ambiguous, ask.

### 9. Create branch and commit

Run:

```bash
git switch -c release/<package>-<version>
git add <docker_dir>
git commit -m "$(cat <<'EOF'
chore(<package>): bump to v<version>

<release-url>

Co-authored-by: Claude <noreply@anthropic.com>
EOF
)"
```

If `git switch -c` fails because the branch already exists, STOP and ask the user how to proceed (delete the stale branch, or use a different name).

### 10. Push and open the PR

Run:

```bash
git push -u origin release/<package>-<version>
gh pr create --title "chore(<package>): bump to v<version>" --body "$(cat <<'EOF'
<release-url>
EOF
)"
```

Print the PR URL. STOP. Do not merge — per `AGENTS.md`, agents never merge without explicit per-PR confirmation.

## Things to double-check

- The `[package].name` in `build.toml` matches the `package` field in the mapping entry. If it doesn't, the mapping is wrong — fix the mapping, not the build.toml.
- Only reset `[package].build` to `"1"` if that field already existed in the file.
- Do not edit `[vars]` for any repo other than `ethereum/go-ethereum`.
- Do not invent URLs. Only fetch the exact URLs specified: the user-provided release URL and `https://geth.ethereum.org/downloads` for the Ethereum special case.
- Branch name is `release/<package>-<version>` where `<version>` has no leading `v`.
- Commit subject includes the `v` prefix: `chore(<package>): bump to v<version>`.
