# ~/.zshrc — managed by ~/Documents/Work/env
#
# fish is the login shell, so zsh is only a fallback: you reach it by typing
# `zsh`, or on a fresh machine before install.sh has run chsh. Both of those
# are interactive NON-login shells, which read .zshenv and .zshrc but never
# .zprofile — so everything lives here rather than split across two files.

# Homebrew. Sets PATH, MANPATH, INFOPATH and the HOMEBREW_* variables, so it
# replaces a bare PATH export. Guarded so this file works before brew exists.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Google Cloud SDK (gcloud-cli cask, under the brew prefix)
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then
  . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then
  . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'
fi

export META_DIR="$HOME/Documents/Work/meta"

# Runtimes (node etc.) — versions pinned in ~/.config/mise/config.toml
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
