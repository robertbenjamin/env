# FISH GREETING

set fish_greeting

# GIT ALIASES

alias gd="git diff"
alias ga="git add"
alias gcm="git commit -m"
alias gbd="git branch -D"
alias gs="git status -sb --ignore-submodules"
alias gm="git merge"
alias gp="git push"
alias gpu="git pull"
alias grh="git reset --hard"
alias grpo="git remote prune origin"
alias gb="git branch"
alias gcob="git checkout -b"
alias gco="git checkout"
alias gfo="git fetch origin"
alias gpo="git pull origin"
alias gpom="git pull origin master"
alias fh="gpo; git remote prune origin; git prune"

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
