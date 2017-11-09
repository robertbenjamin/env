# FISH GREETING

set fish_greeting "Hmm."

# ALIASES

alias gd="git diff"
alias ga="git add"
alias gcm="git commit -m"
alias gbd="git branch -D"
alias gst="git status -sb --ignore-submodules"
alias gm="git merge"
alias gp="git push"
alias gpu="git pull"
alias grh="git reset --hard"
alias gb="git branch"
alias gcob="git checkout -b"
alias gco="git checkout"
alias gfo="git fetch origin"
alias gpo="git pull origin"
alias gpom="git pull origin master"
alias fresh="gfo; gpo; git remote prune origin; dingus setup api-dev"

alias gu="gitup"

alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

alias sfish="source /Users/robertbenjamin/.config/fish/config.fish"

alias n="nvim ."

# ENV VARIABLES

# set -x ENV_VARIABLE_NAME 'ENV_VARIABLE_VALUE'
# set PATH YOUR_PATH $PATH

# MISC

## NODENV

status --is-interactive; and source (nodenv init -|psub)

## POSTGRES.APP

set PATH /Applications/Postgres.app/Contents/Versions/latest/bin $PATH

## AUTOJUMP

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
