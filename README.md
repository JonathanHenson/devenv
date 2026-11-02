# devenv

My macOS development environment, as code. One command sets up a new Mac with my
shell, toolchains (C/C++, Rust, Python, Node/CDK, AWS), editor, and coding-agent
configuration. Re-running it is safe; it only changes what's out of date.

Built on [chezmoi](https://www.chezmoi.io/) and Homebrew. Feel free to fork it.

## Quick start

```bash
curl -fsSL https://raw.githubusercontent.com/JonathanHenson/devenv/main/install.sh | bash
```

This installs Xcode Command Line Tools and Homebrew if missing, clones this repo to
`~/source/devenv`, asks a few questions (name, email, optional profiles, AWS details),
then installs everything. Afterwards, open a new terminal and run:

```bash
devenv doctor
```

```bash
devenv ssh-setup
```

`ssh-setup` creates this machine's SSH key (if needed), logs in to GitHub, and uploads
the key for both authentication and commit signing.

## What you get

| Area | Details |
|---|---|
| C / C++ | CMake, Ninja, ccache, Homebrew LLVM (clangd, clang-format, clang-tidy); Apple clang stays the default compiler |
| Rust | rustup stable, rust-analyzer, clippy, linux/arm64 target, cargo-lambda, cargo-zigbuild, nextest, watch, edit, expand |
| Python | uv-managed Python 3.12 / 3.13, ruff, pre-commit, ipython |
| AWS | AWS CLI v2, Session Manager plugin, CDK (via mise + Node LTS), AgentCore starter toolkit (`agentcore`), OrbStack for arm64 containers |
| Shell | zsh with starship prompt, autosuggestions, syntax highlighting, fzf, zoxide, direnv, eza, bat |
| Git | delta, SSH commit signing, rerere, rebase-on-pull, gh as credential helper |
| VS Code | clangd, CMake Tools, CodeLLDB, rust-analyzer, Python/Ruff, AWS Toolkit, GitLens, Claude Code; shared settings |
| Agents | Shared `AGENTS.md`, Claude Code settings, skills, and AWS MCP servers |

Optional **bindings** profile: Java (Temurin 21 via mise), Maven, Gradle, .NET SDK.

## Layout

```
install.sh                   bootstrap entry point
brew/Brewfile.*              Homebrew packages (core, bindings, apps)
bin/devenv                   helper CLI (symlinked to ~/.local/bin/devenv)
agents/claude/               Claude Code settings + MCP servers (merged into ~/.claude)
agents/vscode/settings.json  VS Code settings (merged into the live settings file)
home/                        chezmoi source: files that land in $HOME
  .chezmoi.toml.tmpl         prompts and machine data
  .chezmoiscripts/           install steps (brew, rust, python, mise, vscode, claude)
  dot_config/agents/AGENTS.md  shared instructions for every coding agent
  dot_claude/                CLAUDE.md and skills
```

## Day to day

| Command | What it does |
|---|---|
| `devenv doctor` | Check that everything is installed and configured |
| `devenv apply` | Apply repo changes to this machine |
| `devenv update` | Pull the repo and upgrade brew, Rust, uv tools and mise runtimes |
| `devenv edit` | Open the repo in VS Code |
| `devenv aws-login` / `aws-check` | Log in to AWS / show the active role |
| `devenv secret get\|put <id>` | Read or write a secret in AWS Secrets Manager |

To change something: edit the file in `~/source/devenv`, run `devenv apply`, commit.
To change your setup answers (profiles, AWS details): `chezmoi init`.

Machine-specific tweaks go in unmanaged files that devenv sources if present:
`~/.zshrc.local`, `~/.zshenv.local`, `~/.gitconfig.local`, `~/.ssh/config.local`.

## AWS setup (one time, personal account)

devenv logs in to AWS through **IAM Identity Center**: you sign in in the browser (with
MFA), and AWS issues credentials that expire after a few hours. No long-lived access
keys exist anywhere. For a personal account you need **one permission set and no extra
IAM roles**.

### In the AWS console (about 10 minutes)

1. **Lock down the root user.** Enable MFA on it and delete any root access keys. After
   this setup, sign in through the access portal instead of as root.
2. **Enable IAM Identity Center** and choose **Enable with AWS Organizations** (an
   *organization instance*). An *account instance* can't grant access to AWS accounts.
   Your account becomes the organization's management account, at no cost.
3. *(Optional, one-time)* **Settings → Identity source → Customize** the access portal URL,
   e.g. `https://yourname.awsapps.com/start`. Do it before step 9; it can't be changed later.
4. **Settings → Authentication → MFA → Configure**: prompt *every time they sign in*;
   allow *security keys and built-in authenticators* (Touch ID/passkeys) and
   *authenticator apps*; *require them to register a device at sign-in*.
5. **Settings → Authentication → Session duration**: 8–12 hours. This is how often
   `aws sso login` opens the browser.
6. **Users → Add user** with your email. Accept the invite, set a password, register MFA.
7. **Permission sets → Create → Predefined → AdministratorAccess**, session duration 8 hours.
8. **AWS accounts →** select your account **→ Assign users or groups →** your user →
   `AdministratorAccess`.
9. Note the **AWS access portal URL** (Identity Center dashboard), the **region** Identity
   Center runs in, and your 12-digit **account ID**.
10. *(Recommended)* **Billing → Budgets →** create a monthly cost budget with an email alert.

### On the Mac

```bash
chezmoi init
```

Answer the AWS prompts: portal URL, Identity Center region, account ID,
`AdministratorAccess`, **leave the extra-role prompt blank**, and your default region. Then:

```bash
devenv aws-login
```

```bash
devenv aws-check
```

`aws-check` should show `assumed-role/AWSReservedSSO_AdministratorAccess_.../<you>`.
`AWS_PROFILE=personal` is exported in every shell, so the CLI, CDK, `agentcore` and SDKs
all use it. The CLI refreshes credentials on its own until the login session from step 5
expires.

### Optional: separate admin role

To keep day-to-day access read-only and switch to admin deliberately: create a permission
set with `ReadOnlyAccess` plus an inline policy allowing `sts:AssumeRole` on one role.
Then create an IAM role (e.g. `Admin`) with `AdministratorAccess`. Its trust policy names
`arn:aws:iam::<account>:root` as the principal, with a condition
`ArnLike aws:PrincipalArn = arn:aws:iam::<account>:role/aws-reserved/sso.amazonaws.com/*/AWSReservedSSO_<PermissionSet>_*`.
Give that permission set and role name to `chezmoi init`. Most solo setups don't need
this: CDK and AgentCore deploys need admin anyway.

## Secrets

Secrets live in **AWS Secrets Manager**, never in this repo or on disk in plain text.

```bash
devenv secret put devenv/github-token
```

List the secrets you want in your shell in `~/.config/devenv/secrets` (`ENV_VAR=secret-id`),
then run `load-secrets` in any terminal to export them.

## Coding agents

`~/.config/agents/AGENTS.md` is the single source of instructions for every agent.
Claude Code imports it from `~/.claude/CLAUDE.md`; Codex reads it through a symlink at
`~/.codex/AGENTS.md`. Adding another agent means pointing its config at the same file.

Claude Code also gets:
- `agents/claude/settings.json`: permission allow/ask lists, merged into
  `~/.claude/settings.json` without clobbering settings the app writes.
- `agents/claude/mcp-servers.json`: user-scope MCP servers (AWS docs, IaC, AgentCore),
  registered with `claude mcp add-json`.
- Skills in `home/dot_claude/skills/`: CMake build/test, CDK workflow, AgentCore Rust
  deploy, ship a PR.

## CI

GitHub Actions runs the full non-interactive install on a clean macOS runner (with and
without the bindings profile), checks that a second apply changes nothing, and runs
`devenv doctor --ci`.
