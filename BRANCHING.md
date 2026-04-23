# Branching

## Base branch

`main` is the base branch. All work lands on `main` through pull requests.

**Never commit directly to `main`.** Every change — including small fixes and version bumps — goes through a feature branch and a PR.

## Branch naming

| Purpose | Pattern | Example |
|---|---|---|
| Version bumps (upstream releases) | `release/<package>-<version>` | `release/bsc-geth-1.7.3` |
| New features | `feat-<short-desc>` or `feat/<short-desc>` | `feat-unify-dockerfiles` |
| Bug fixes | `fix-<short-desc>` | `fix-ci-rust-script-cache` |
| Maintenance / chores | `chore-<short-desc>` | `chore-bump-clap` |
| Renovate-generated | `renovate/...` (managed automatically) | `renovate/chainargos-bor-2.x` |

`<package>` in a release branch matches the `[package].name` in the target `build.toml`. `<version>` is the upstream version without a leading `v`.

## Pull requests

- Approved PRs are merged with a squash merge.
- PR titles use [Conventional Commits](COMMITS.md) — the title becomes the squash commit subject.
- PRs need at least one reviewer (or explicit operator approval for self-merge).
- Agents do not merge PRs without explicit per-PR confirmation from the operator (see [AGENTS.md](AGENTS.md)).

## Force-push

Force-push (`--force-with-lease`) is allowed on feature branches you own, and only on feature branches. Never force-push `main`.
