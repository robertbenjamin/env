# FISH GREETING

set fish_greeting

# GIT ALIASES

abbr gd="git diff"
abbr ga="git add"
abbr gcm="git commit -m"
abbr gbd="git branch -D"
abbr gs="git status -sb --ignore-submodules"
abbr gm="git merge"
abbr gp="git push"
abbr gpu="git pull"
abbr gr="git rebase"
abbr grh="git reset --hard"
abbr grpo="git remote prune origin"
abbr gb="git branch"
abbr gcob="git checkout -b"
abbr gco="git checkout"
abbr gfo="git fetch origin"
abbr gpo="git pull origin"
abbr gpom="git pull origin master"
abbr fh="gpo; git remote prune origin; git prune"

# FINDER ALIASES

alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# FISH ALIASES

alias sfish="source ~/.config/fish/config.fish"

# NODENV

status --is-interactive; and source (nodenv init -|psub)

# GLOBAL NPM PACKAGES

set fish_user_paths (npm config get prefix)/bin

# AUTOJUMP

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

# ENV VARIABLES

# set -x ENV_VARIABLE_NAME 'ENV_VARIABLE_VALUE'
# set PATH YOUR_PATH $PATH
