# Working agreements for coding agents

Shared instructions for every coding agent on this machine (Claude Code, Codex, etc.).
Managed in ~/source/devenv; edit there, then `chezmoi apply`.

## About me
- Systems engineer. Most at home in C (C99), CMake, Rust and Python. I also work with
  AWS CDK and Rust agents deployed to Amazon Bedrock AgentCore.
- I prefer small, reviewable changes and direct explanations. Lead with the answer.

## General
- Read the surrounding code and match its conventions before adding new patterns.
- Don't add dependencies without saying why; prefer the standard library.
- Never commit secrets. Secrets live in AWS Secrets Manager (`load-secrets`).
- Ask before anything destructive or hard to undo: deploys, deletes, force-pushes,
  `cdk destroy`, publishing packages.

## C / C++
- Build with CMake + Ninja out of source in `build/` (`cmk` configures, builds, tests).
- Keep public headers minimal; explicit error handling with return codes, no hidden
  allocation in hot paths; check every allocation and syscall result.
- Format with the repo's `.clang-format`; run `clang-tidy` where configured.
- New behavior gets a test registered with CTest. Run tests under ASan/UBSan
  (`-DCMAKE_C_FLAGS="-fsanitize=address,undefined"`) when touching memory handling.

## Rust
- `cargo clippy --all-targets -- -D warnings` and `cargo fmt` must be clean.
- Prefer `thiserror` for library errors, `anyhow` at binary edges. No `unwrap()` in
  library code outside tests.
- Test with `cargo nextest run`.
- AgentCore deploys target linux/arm64: `cargo lambda build --release --arm64` or
  `cargo zigbuild --target aarch64-unknown-linux-gnu`.

## Python
- Manage with `uv` (`uv run`, `uv add`); format and lint with `ruff`.
- Type hints on public functions; tests with pytest.

## AWS
- Default credentials come from `AWS_PROFILE=personal` (Identity Center + assume-role).
  If calls fail with expired tokens, run `aws sso login --sso-session personal`.
- For CDK: always `cdk diff` before `cdk deploy`, and show me the diff.

## Git
- Conventional, imperative commit subjects (`fix: handle EAGAIN in socket read`).
- One logical change per commit. Don't push or open PRs unless asked.
