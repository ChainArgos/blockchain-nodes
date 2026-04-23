# Node Version Updates

This file documents the workflow for bumping the upstream version of a blockchain node packaged in this repo. It applies to every AI agent (Claude, Codex, Amp) and to humans.

Given a GitHub release URL like `https://github.com/bnb-chain/bsc/releases/tag/v1.7.3`, bump the matching `docker-<pkg>/build.toml`, inspect any chain-config drift, and open a PR. **Never merge** — stop at the PR URL (see [AGENTS.md](AGENTS.md) for the merge gate).

## When to run this workflow

When the user provides, or clearly references, a GitHub release URL for a blockchain node tracked in this repo. Typical phrasings:
- "update bsc to https://github.com/bnb-chain/bsc/releases/tag/v1.7.3"
- "new bor release: https://github.com/0xPolygon/bor/releases/tag/v2.7.1"
- "bump geth https://github.com/ethereum/go-ethereum/releases/tag/v1.17.2"

If the URL does not match `https://github.com/<org>/<repo>/releases/tag/<tag>`, stop and ask for a release URL.

## Workflow

Follow these steps in order. Do not skip the human gate.

### 1. Parse the URL

Extract `org`, `repo`, and `tag` from the path. Examples:
- `https://github.com/bnb-chain/bsc/releases/tag/v1.7.3` → `org=bnb-chain`, `repo=bsc`, `tag=v1.7.3`
- `https://github.com/ethereum-optimism/optimism/releases/tag/op-node/v1.16.12` → `org=ethereum-optimism`, `repo=optimism`, `tag=op-node/v1.16.12`

### 2. Look up the mapping

Read `.node-updates/mappings.toml`. Among entries where `repo == "<org>/<repo>"`, pick the one whose `tag_prefix` is the **longest** prefix of `tag`. An empty `tag_prefix` matches only when no longer prefix is available for the same repo.

If no entry matches, STOP and print:

```
No mapping for <org>/<repo>. Add an entry to .node-updates/mappings.toml:

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

If `<docker_dir>/sync-config.rs` exists: run `./sync-config.rs` with the working directory set to `<docker_dir>`. Treat the script output as **upstream reference material**, not as automatically correct repo content. If the script exits non-zero, STOP — print its output and tell the user the working tree is in a partial state; do not commit.

If `sync-config.rs` does not exist: skip silently.

### 7. Reconcile config drift

Compare the tracked files under `<docker_dir>` before and after running `sync-config.rs`.

Rules:
- Treat the repo's checked-in values as canonical for any option that already existed before the sync. These files often contain local operator-curated settings that must win over upstream defaults.
- Settings such as monikers, listen/advertise addresses, telemetry toggles, Prometheus toggles, engine URLs, JWT paths, and data paths are examples of values that are usually local and should stay unchanged unless the user explicitly approves a change.
- If the sync introduces **new options, new sections, or new files**, STOP and ask the user what to do next. Do not commit those additions automatically.
- If the sync **changes or removes existing values**, restore the pre-sync version of those files before continuing. Summarize the candidate upstream changes for the user, but do not keep them without approval.
- Only keep config-file edits that the user explicitly asked for or approved after seeing the diff.

### 8. Show the diff

Run `git status` and `git diff` and display the output to the user. Summarize what changed in one line (e.g., "Updated bsc-geth from v1.7.2 to v1.7.3; refreshed config/config.toml and config/genesis.json.").

If you restored config files after inspecting sync output, say so explicitly and describe the upstream-only changes separately from the remaining diff.

### 9. HUMAN GATE — wait for confirmation

STOP and wait for the user to explicitly confirm. Acceptable confirmations: "yes", "proceed", "ship it", "looks good, commit it", "go ahead".

If the user declines or asks for changes, do not commit. Leave the edits on disk so they can adjust.

Do not commit just because the user says "looks good" without "commit" / "proceed" / "ship" — if it's ambiguous, ask.

### 10. Create branch and commit

Use the agent-attribution trailer for **whichever agent you are**, per [COMMITS.md](COMMITS.md):

- Claude → `Co-authored-by: Claude <noreply@anthropic.com>`
- Codex → `Co-authored-by: Codex <codex@openai.com>`
- Amp → `Co-authored-by: Amp <amp@ampcode.com>` (plus the optional `Amp-Thread-ID:` metadata trailer if your tool emits it)

Exactly one agent trailer per commit — never stack multiple.

Run:

```bash
git switch -c release/<package>-<version>
git add <docker_dir>
git commit -m "$(cat <<'EOF'
chore(<package>): bump to v<version>

<release-url>

Co-authored-by: <your-agent-trailer>
EOF
)"
```

If `git switch -c` fails because the branch already exists, STOP and ask the user how to proceed.

### 11. Push and open the PR

Run:

```bash
git push -u origin release/<package>-<version>
gh pr create --title "chore(<package>): bump to v<version>" --body "$(cat <<'EOF'
<release-url>
EOF
)"
```

Print the PR URL. STOP. Do not merge — per [AGENTS.md](AGENTS.md), agents never merge without explicit per-PR confirmation.

## Things to double-check

- The `[package].name` in `build.toml` matches the `package` field in the mapping entry. If it doesn't, the mapping is wrong — fix the mapping, not the build.toml.
- Only reset `[package].build` to `"1"` if that field already existed in the file.
- Do not edit `[vars]` for any repo other than `ethereum/go-ethereum`.
- Do not invent URLs. Only fetch the exact URLs specified: the user-provided release URL and `https://geth.ethereum.org/downloads` for the Ethereum special case.
- For nodes with `sync-config.rs`, never treat upstream defaults as authoritative for existing checked-in config values. Local tracked config wins unless the user approves a change.
- Branch name is `release/<package>-<version>` where `<version>` has no leading `v`.
- Commit subject includes the `v` prefix: `chore(<package>): bump to v<version>`.
- Use the agent trailer matching **your own** agent tool, not someone else's.
