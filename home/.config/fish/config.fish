# ~/.config/fish/config.fish — managed by ~/Documents/Work/env
#
# Everything here is declarative and safe to re-run. Note that all PATH
# additions use `fish_add_path -g` (global scope) rather than the default
# universal scope: universal writes land in ~/.config/fish/fish_variables,
# which this repo deliberately does not manage. Global scope is rebuilt from
# this file on every shell start, so the file stays the single source of truth.

# GREETING

set fish_greeting

# GIT ABBREVIATIONS

abbr -a -g gd git diff
abbr -a -g ga git add
abbr -a -g gcm git commit -m
abbr -a -g gcme "git commit -m 'Trigger build' --allow-empty"
abbr -a -g gbd git branch -D
abbr -a -g gp git push
abbr -a -g gpu git pull
abbr -a -g gr git rebase
abbr -a -g grm git rebase master
abbr -a -g gb git branch
abbr -a -g gco git checkout
abbr -a -g gcol git checkout -
abbr -a -g gcom git checkout master
abbr -a -g gcob git checkout -b
abbr -a -g gpo git pull origin
abbr -a -g gpom git pull origin master
abbr -a -g fh "git pull origin; git remote prune origin; git prune"
abbr -a -g grc git rebase --continue
abbr -a -g gsu "git submodule foreach git pull origin main"

# FINDER ALIASES

alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# FISH ALIASES

alias sfish="source ~/.config/fish/config.fish"

# OTHER ABBREVIATIONS

abbr -a -g c "code"

# HOMEBREW

status is-interactive; and /opt/homebrew/bin/brew shellenv fish | source

# AUTOJUMP

[ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

# RUNTIMES (node etc.) — see ~/.config/mise/config.toml for pinned versions
#
# `mise activate` installs its own directory-change hook, so per-project
# versions are picked up automatically; there is no equivalent of fnm's
# --use-on-cd to pass. Guarded so a shell still opens cleanly before the
# brew stage of install.sh has run.

if command -q mise
    mise activate fish | source
end

set -gx PNPM_HOME $HOME/Library/pnpm
fish_add_path -g $PNPM_HOME

# POSTGRESQL

fish_add_path -g /opt/homebrew/opt/postgresql@17/bin

# GOOGLE CLOUD SDK (installed via the gcloud-cli cask, under the brew prefix)

if [ -f /opt/homebrew/share/google-cloud-sdk/path.fish.inc ]
    source /opt/homebrew/share/google-cloud-sdk/path.fish.inc
end

# OTHER PATHS

fish_add_path -g /usr/local/sbin
fish_add_path -g $HOME/.local/bin

# ITERM2 SHELL INTEGRATION

test -e $HOME/.iterm2_shell_integration.fish; and source $HOME/.iterm2_shell_integration.fish; or true

# PROMPT (must stay last)

starship init fish | source
