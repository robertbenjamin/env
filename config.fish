# FISH GREETING

set fish_greeting

# GIT ALIASES

abbr -a -g gd git diff
abbr -a -g ga git add
abbr -a -g gcm git commit -m
abbr -a -g gbd git branch -D
abbr -a -g gs git status -sb --ignore-submodules
abbr -a -g gm git merge
abbr -a -g gp git push
abbr -a -g gpu git pull
abbr -a -g gr git rebase
abbr -a -g grh git reset --hard
abbr -a -g grpo git remote prune origin
abbr -a -g gb git branch
abbr -a -g gcob git checkout -b
abbr -a -g gco git checkout
abbr -a -g gfo git fetch origin
abbr -a -g gpo git pull origin
abbr -a -g gpom git pull origin master
abbr -a -g fh "git pull origin; git remote prune origin; git prune"

# FINDER ALIASES

alias show="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app"
alias hide="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app"

# FISH ALIASES

alias sfish="source ~/.config/fish/config.fish"

# NODENV

status --is-interactive; and source (nodenv init -|psub)

# GLOBAL NPM PACKAGES

set fish_user_paths (npm config get prefix)/bin

# RBENV

status --is-interactive; and source (rbenv init -|psub)

# AUTOJUMP

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

# YARN

set YARNPATH $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin

# GO

set GOPATH $HOME/go/bin

# ADD PATHS

set PATH $GOPATH $YARNPATH $PATH

# ENV VARIABLES

# set -x ENV_VARIABLE_NAME 'ENV_VARIABLE_VALUE'
# set PATH YOUR_PATH $PATH
