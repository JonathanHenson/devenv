# PATH setup, sourced from both .zshenv and .zprofile.
# (.zprofile re-applies it because macOS /etc/zprofile's path_helper reorders PATH.)
export HOMEBREW_PREFIX=/opt/homebrew
export HOMEBREW_CELLAR=/opt/homebrew/Cellar
export HOMEBREW_REPOSITORY=/opt/homebrew
typeset -U path PATH fpath
path=(
  $HOME/.local/bin
  $HOME/.cargo/bin
  $HOME/.local/share/mise/shims
  $HOME/.orbstack/bin
  $HOMEBREW_PREFIX/bin
  $HOMEBREW_PREFIX/sbin
  $path
  # Appended last: clangd/clang-format/clang-tidy come from Homebrew llvm,
  # while clang/lldb still resolve to Apple's toolchain in /usr/bin.
  $HOMEBREW_PREFIX/opt/llvm/bin
  "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
)
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)
