# Files
if _has eza; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2'
fi
alias ..='cd ..'
alias ...='cd ../..'

# Git
alias g='git'
alias gs='git status -sb'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gsw='git switch'
alias gp='git push'
alias gpl='git pull'

# CMake (Ninja is the default generator via CMAKE_GENERATOR)
alias cb='cmake --build build'
alias ct='ctest --test-dir build --output-on-failure'

# Rust
alias cn='cargo nextest run'
alias cclip='cargo clippy --all-targets -- -D warnings'

# AWS
alias awsl='aws sso login --sso-session personal'
alias awsw='aws sts get-caller-identity'

# devenv
alias dotfiles='cd ~/source/devenv'
