#!/usr/bin/env bash
# devenv bootstrap: sets up a new Mac from this repo.
#
#   curl -fsSL https://raw.githubusercontent.com/JonathanHenson/devenv/main/install.sh | bash
#
# Environment overrides:
#   DEVENV_REPO            git URL to clone (default: this repo on GitHub)
#   DEVENV_SOURCE          where the repo lives locally (default: ~/source/devenv)
#   DEVENV_NONINTERACTIVE  set to 1 to skip prompts and use defaults (CI)
#   DEVENV_NAME / DEVENV_EMAIL / DEVENV_BINDINGS   prompt defaults
set -euo pipefail

REPO="${DEVENV_REPO:-https://github.com/JonathanHenson/devenv.git}"
SRC="${DEVENV_SOURCE:-$HOME/source/devenv}"
NONINTERACTIVE="${DEVENV_NONINTERACTIVE:-}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "devenv currently supports macOS only." >&2
  exit 1
fi

# 1. Xcode Command Line Tools (git, clang, make).
if ! xcode-select -p >/dev/null 2>&1; then
  log "Installing Xcode Command Line Tools (accept the dialog)..."
  xcode-select --install || true
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
fi

# 2. Homebrew.
BREW=/opt/homebrew/bin/brew
[[ -x "$BREW" ]] || BREW=/usr/local/bin/brew
if [[ ! -x "$BREW" ]]; then
  log "Installing Homebrew..."
  NONINTERACTIVE="$NONINTERACTIVE" /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW=/opt/homebrew/bin/brew
fi
eval "$("$BREW" shellenv)"

# 3. chezmoi.
command -v chezmoi >/dev/null 2>&1 || { log "Installing chezmoi..."; brew install chezmoi; }

# 4. Clone (if needed) and apply.
args=(init --apply --source "$SRC")
if [[ ! -d "$SRC/.git" ]]; then
  mkdir -p "$(dirname "$SRC")"
  args+=("$REPO")
fi

if [[ -n "$NONINTERACTIVE" ]]; then
  log "Applying devenv (non-interactive)..."
  chezmoi "${args[@]}" --no-tty --promptDefaults
elif [[ -r /dev/tty ]]; then
  # stdin is the curl pipe; prompts need the real terminal.
  log "Applying devenv..."
  chezmoi "${args[@]}" </dev/tty
else
  chezmoi "${args[@]}"
fi

log "Done. Open a new terminal, then run: devenv doctor"
