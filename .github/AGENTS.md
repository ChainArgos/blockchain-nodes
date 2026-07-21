# GitHub Actions runner policy

Every executable workflow uses the `lanes` input and the canonical inline
`matrix.config` expression: Velnor by default, pinned `ubuntu-26.04` for the
GitHub comparison lane, and `both` for parity. State mutation is gated by
`matrix.config.writer`, so the secondary lane is read-only.
The canonical Sunday schedule selects `both`; other automatic events remain
Velnor-default.

This repository uses rust-script as its primary workflow toolchain. Cache its
explicit Rust source set with a versioned, non-empty key; do not add a second
compiler-cache layer without measured evidence and contract approval.
