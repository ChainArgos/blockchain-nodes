# Commits

This file covers commit message format. It applies to every commit in this repository.

## Commit Messages

All commits MUST follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Subject format: `<type>[optional scope][!]: <description>`

Allowed types:

| Type | Use for |
|---|---|
| `feat` | New user-visible feature |
| `fix` | Bug fix |
| `docs` | Documentation-only change |
| `style` | Formatting, whitespace; no logic change |
| `refactor` | Internal restructuring; no behavior change |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system, tooling, dependencies |
| `ci` | CI configuration |
| `chore` | Routine maintenance (release, merge, deps) |
| `revert` | Reverts a prior commit |

Scope is optional but encouraged when it clarifies the change area, e.g., `chore(bsc-geth): bump to v1.7.3` or `fix(docker-build): handle missing platforms`.

Breaking changes use `!` after the type/scope (`feat!:` or `feat(api)!:`) and include a `BREAKING CHANGE:` footer in the body.

PRs are squash-merged, so the PR title becomes the commit subject and must also follow this convention.

## What this repo does NOT require

- **No DCO sign-off.** `git commit -s` is not needed.
- **No mandatory pre-commit test runs.** This repo is a collection of Rust scripts (`*.rs` via `rust-script`) and Docker assets; run `cargo fmt` and `cargo clippy` when you've modified Rust code, but they are not gates on every commit.
