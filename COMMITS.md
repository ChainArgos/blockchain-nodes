# Commits

This file covers commit message format and agent attribution. Both apply to every commit in this repository.

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

PR squash-merge: the PR title becomes the commit subject, so PR titles must also follow this convention.

## Agent Attribution

Every commit created by an AI agent MUST include exactly one `Co-authored-by` trailer identifying the agent. The trailer identifies the **agent tool**, not the underlying model. Never stack multiple agent trailers on one commit.

Trailers per agent:

- **Claude** (Claude Code CLI, or any Claude-API coding agent used directly):

  ```text
  Co-authored-by: Claude <noreply@anthropic.com>
  ```

- **Codex** (OpenAI Codex CLI):

  ```text
  Co-authored-by: Codex <codex@openai.com>
  ```

- **Amp** (Sourcegraph Amp, regardless of underlying model):

  ```text
  Co-authored-by: Amp <amp@ampcode.com>
  ```

Amp may additionally emit an `Amp-Thread-ID:` metadata trailer; that is acceptable alongside the single `Co-authored-by: Amp` trailer because the thread ID identifies the conversation, not a second agent.

See [AGENTS.md](AGENTS.md) for the agent-attribution rule and its rationale. If you are uncertain which agent is creating the commit, ask — wrong attribution is worse than no attribution.

## What this repo does NOT require

- **No DCO sign-off.** `git commit -s` is not needed.
- **No mandatory pre-commit test runs.** This repo is a collection of Rust scripts (`*.rs` via `rust-script`) and Docker assets; run `cargo fmt` and `cargo clippy` when you've modified Rust code, but they are not gates on every commit.
