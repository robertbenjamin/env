# FISH GREETING

set fish_greeting "Dammit, Robert."

# SETUP SELFCONTROL BLOCK LENGTH

defaults write org.eyebeam.SelfControl MaxBlockLength -int 60

# ALIASES

alias undopush="git push -f origin HEAD^:master"
alias gd="git diff"
alias gdi="git icdiff"
alias ga="git add"
alias gcm="git commit -m"
alias gbd="git branch -D"
alias gst="git status -sb --ignore-submodules"
alias gm="git merge --no-ff"
alias gpt="git push --tags"
alias gp="git push"
alias gpu="git pull"
alias grs="git reset --soft"
alias grh="git reset --hard"
alias gb="git branch"
alias gcob="git checkout -b"
alias gco="git checkout"
alias gba="git branch -a"
alias gcp="git cherry-pick"
alias gl="git lg"
alias gpom="git pull origin master"
alias gf="git fetch"

alias gu="gitup"

alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

alias sfish="source /Users/robertbenjamin/.config/fish/config.fish"

alias r="ranger"

alias n="nvim ."

# ENV VARIABLES

# set -x -g ENV_VARIABLE_NAME 'ENV_VARIABLE_VALUE'

# MISC

## RUBY SHIMS

status --is-interactive; and source (rbenv init -|psub)

## YARN

set -x -g PATH (yarn global bin) $PATH

## GRUNT

eval (grunt --completion=bash)

## AUTOJUMP

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish
