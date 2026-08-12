#!/bin/bash
#
# Bootstrap a macOS machine to match this repo. Idempotent — safe to re-run.
#
#   ./install.sh                 full run
#   ./install.sh --dry-run       print every action, change nothing
#   ./install.sh --skip-brew     skip Homebrew install and `brew bundle`
#   ./install.sh --no-shell      skip the chsh step (the only sudo prompt)
#   ./install.sh --only links    run a single stage
#
# Stages, in run order: brew links runtimes claude iterm shell
#   (runtimes follows links because mise reads the symlinked config file)
#
# Written for macOS's stock /bin/bash 3.2 — no associative arrays, no readarray.
# Every path is derived from "$HOME", so the whole script can be exercised
# against a throwaway home directory:
#
#   HOME=/tmp/fakehome ./install.sh --skip-brew --no-shell

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$REPO/home"
BREW_PREFIX="/opt/homebrew"
BACKUP_DIR="$HOME/.env-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
SKIP_BREW=0
NO_SHELL=0
ONLY=""
BACKUP_MADE=0
CHANGES=0

# ---------------------------------------------------------------- output ----

if [ -t 1 ]; then
  BOLD=$(printf '\033[1m'); DIM=$(printf '\033[2m'); RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m'); YELLOW=$(printf '\033[33m'); RESET=$(printf '\033[0m')
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; RESET=""
fi

stage() { printf '\n%s==> %s%s\n' "$BOLD" "$1" "$RESET"; }
ok()    { printf '    %s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
skip()  { printf '    %s·%s %s\n' "$DIM" "$RESET" "$DIM$1$RESET"; }
warn()  { printf '    %s!%s %s\n' "$YELLOW" "$RESET" "$1"; }
die()   { printf '\n%serror:%s %s\n' "$RED" "$RESET" "$1" >&2; exit 1; }
act()   { CHANGES=$((CHANGES + 1)); printf '    %s+%s %s\n' "$GREEN" "$RESET" "$1"; }

# Run a command, or just describe it under --dry-run.
run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '    %swould run:%s %s\n' "$DIM" "$RESET" "$*"
  else
    "$@"
  fi
}

wants() { [ -z "$ONLY" ] || [ "$ONLY" = "$1" ]; }

# ------------------------------------------------------------------ args ----

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run)   DRY_RUN=1 ;;
    --skip-brew) SKIP_BREW=1 ;;
    --no-shell)  NO_SHELL=1 ;;
    --only)      shift; [ $# -gt 0 ] || die "--only needs a stage name"; ONLY="$1" ;;
    -h|--help)   sed -n '2,20p' "$0" | sed 's/^#\{1,2\} \{0,1\}//'; exit 0 ;;
    *)           die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

case "$ONLY" in
  ""|brew|links|runtimes|claude|iterm|shell) ;;
  *) die "unknown stage: $ONLY (brew links runtimes claude iterm shell)" ;;
esac

# -------------------------------------------------------------- preflight ---

stage "Preflight"

[ "$(uname -s)" = "Darwin" ] || die "this script is macOS only (found $(uname -s))"
[ -d "$HOME_SRC" ] || die "no home/ directory in $REPO — wrong checkout?"
ok "macOS $(sw_vers -productVersion), repo at $REPO"
[ "$DRY_RUN" -eq 1 ] && warn "dry run — nothing will be changed"

if [ "$(uname -m)" != "arm64" ]; then
  warn "not arm64 — this repo assumes the Apple Silicon brew prefix ($BREW_PREFIX)"
fi

if ! xcode-select -p >/dev/null 2>&1; then
  warn "Xcode Command Line Tools missing — launching the installer"
  run xcode-select --install
  die "re-run this script once the Command Line Tools have finished installing"
fi
ok "Xcode Command Line Tools present"

# ------------------------------------------------------------------ brew ----

if wants brew && [ "$SKIP_BREW" -eq 0 ]; then
  stage "Homebrew"

  if ! command -v brew >/dev/null 2>&1; then
    if [ -x "$BREW_PREFIX/bin/brew" ]; then
      eval "$("$BREW_PREFIX/bin/brew" shellenv)"
      ok "found existing Homebrew at $BREW_PREFIX"
    else
      act "installing Homebrew"
      run /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      [ "$DRY_RUN" -eq 1 ] || eval "$("$BREW_PREFIX/bin/brew" shellenv)"
    fi
  else
    ok "brew $(brew --version | head -1 | awk '{print $2}')"
  fi

  # Casks are installed here rather than left to `brew bundle`, so that --adopt
  # can be passed. Apps installed by hand before this repo existed are otherwise
  # fatal: `brew install --cask iterm2` aborts with "It seems there is already
  # an App at '/Applications/iTerm.app'", which would take the whole script down
  # before the symlink stage. --adopt takes over the existing app instead, and
  # is a normal install when nothing is there. HOMEBREW_CASK_OPTS cannot carry
  # it (that only supports --*dir, --language, --require-sha, --no-binaries).
  INSTALLED_CASKS="$(mktemp -t env-casks)"
  brew list --cask -1 2>/dev/null | sort > "$INSTALLED_CASKS"

  while IFS= read -r line; do
    case "$line" in
      cask\ \"*)
        cname=$(printf '%s' "$line" | sed -e 's/^cask "//' -e 's/".*$//')
        if grep -qxF "$cname" "$INSTALLED_CASKS"; then
          skip "cask $cname"
        else
          act "brew install --cask --adopt $cname"
          run brew install --cask --adopt "$cname" \
            || warn "cask $cname failed — continuing"
        fi
        ;;
    esac
  done < "$REPO/Brewfile"
  rm -f "$INSTALLED_CASKS"

  # Formulae and taps. A no-op for anything already present, and non-fatal so a
  # single unavailable package cannot stop the symlink stage from running.
  act "brew bundle (formulae, plus anything still missing)"
  run brew bundle --file="$REPO/Brewfile" \
    || warn "brew bundle reported problems — continuing"
elif wants brew; then
  stage "Homebrew"
  skip "skipped (--skip-brew)"
fi

# ----------------------------------------------------------- claude code ----

if wants claude; then
  stage "Claude Code"

  if command -v claude >/dev/null 2>&1; then
    ok "claude already installed ($(command -v claude))"
  elif [ -x "$HOME/.local/bin/claude" ]; then
    ok "claude already installed ($HOME/.local/bin/claude)"
  else
    # Not available through Homebrew; this is the official installer.
    act "installing Claude Code"
    run /bin/bash -c "$(curl -fsSL https://claude.ai/install.sh)"
  fi
fi

# --------------------------------------------------------------- symlinks ---

# Link one repo file to its counterpart under $HOME, backing up whatever is
# already there. $1 is the path relative to home/.
link_one() {
  local rel src dst
  rel="$1"
  src="$HOME_SRC/$rel"
  dst="$HOME/$rel"

  # Already pointing where we want it.
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    skip "$rel"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    # A real file, a directory, or a symlink somewhere else — preserve it.
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '    %swould back up:%s ~/%s\n' "$DIM" "$RESET" "$rel"
    else
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$dst" "$BACKUP_DIR/$rel"
      BACKUP_MADE=1
    fi
  fi

  run mkdir -p "$(dirname "$dst")"
  run ln -sfn "$src" "$dst"
  act "~/$rel"
}

if wants links; then
  stage "Symlinks"

  # The home/ tree mirrors $HOME exactly, so the directory structure *is* the
  # mapping — there is no separate manifest to keep in sync.
  #
  # The file list goes via a temp file rather than a pipe into `while`: a
  # pipeline would run the loop in a subshell, discarding link_one's updates
  # to CHANGES and BACKUP_MADE.
  LINK_LIST="$(mktemp -t env-links)"
  ( cd "$HOME_SRC" && find . -type f ! -name '.DS_Store' -print ) \
    | sed 's|^\./||' | sort > "$LINK_LIST"

  while IFS= read -r rel; do
    link_one "$rel"
  done < "$LINK_LIST"
  rm -f "$LINK_LIST"

  if [ -d "$BACKUP_DIR" ]; then
    warn "replaced files backed up to $BACKUP_DIR"
  fi
fi

# -------------------------------------------------------------- runtimes ----

# Deliberately after the symlink stage: mise reads the pinned versions from
# ~/.config/mise/config.toml, which is one of the files that stage links.
if wants runtimes; then
  stage "Runtimes (mise)"

  if ! command -v mise >/dev/null 2>&1; then
    warn "mise not on PATH — skipping (run the brew stage first)"
  elif [ ! -f "$HOME/.config/mise/config.toml" ]; then
    warn "~/.config/mise/config.toml not linked — run './install.sh --only links' first"
  else
    # Nothing to parameterise: the config file is the spec, and `mise install`
    # reconciles the machine to it. A no-op when already satisfied.
    act "mise install (node plus global npm tooling)"
    run mise install
    [ "$DRY_RUN" -eq 1 ] || mise ls --installed 2>/dev/null | sed 's/^/      /'
  fi
fi

# ---------------------------------------------------------------- iterm2 ----

if wants iterm; then
  stage "iTerm2"

  # macOS pgrep has no -q, hence the redirect.
  if pgrep -x iTerm2 >/dev/null 2>&1 || pgrep -x iTerm >/dev/null 2>&1; then
    warn "iTerm2 is running — quit it and re-run '--only iterm', or it will"
    warn "overwrite these settings from memory when it next exits"
  fi

  # iTerm2 reads and writes com.googlecode.iterm2.plist inside this folder, so
  # preference changes made in the GUI land in the repo as reviewable diffs.
  act "pointing iTerm2 at $REPO/iterm2"
  run defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$REPO/iterm2"
  run defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
fi

# ----------------------------------------------------------- login shell ----

if wants shell && [ "$NO_SHELL" -eq 0 ]; then
  stage "Login shell"

  FISH="$BREW_PREFIX/bin/fish"

  # Ask Directory Services what the login shell actually is. $SHELL only
  # describes the process that happened to invoke this script, so it reads
  # /bin/zsh under most tooling even when fish is the real login shell — which
  # would make this stage run chsh, and prompt for a password, unnecessarily.
  LOGIN_SHELL="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')"
  [ -n "$LOGIN_SHELL" ] || LOGIN_SHELL="${SHELL:-}"

  if [ ! -x "$FISH" ]; then
    warn "$FISH not found — skipping (run the brew stage first)"
  elif [ "$LOGIN_SHELL" = "$FISH" ]; then
    ok "fish is already the login shell"
  else
    if ! grep -qxF "$FISH" /etc/shells 2>/dev/null; then
      act "adding $FISH to /etc/shells (needs sudo)"
      if [ "$DRY_RUN" -eq 1 ]; then
        printf '    %swould run:%s sudo tee -a /etc/shells\n' "$DIM" "$RESET"
      else
        printf '%s\n' "$FISH" | sudo tee -a /etc/shells >/dev/null
      fi
    fi
    act "chsh -s $FISH"
    run chsh -s "$FISH"
  fi
elif wants shell; then
  stage "Login shell"
  skip "skipped (--no-shell)"
fi

# ------------------------------------------------------------ next steps ----

stage "Done"

if [ "$DRY_RUN" -eq 1 ]; then
  printf '    dry run complete — %s action(s) would have been taken\n' "$CHANGES"
  exit 0
fi

printf '    %s change(s) applied\n' "$CHANGES"
[ "$BACKUP_MADE" -eq 1 ] && printf '    backups: %s\n' "$BACKUP_DIR"

cat <<'STEPS'

    Manual steps — these need a browser or a credential and cannot be scripted:

      1. Sign in to 1Password.
      2. gh auth login --git-protocol ssh
         One browser flow that authenticates gh AND handles the SSH key: it
         detects existing keys and offers to generate and upload one if none
         is found. The key it writes, ~/.ssh/id_ed25519, is already in ssh's
         default identity list, so no ~/.ssh/config is needed.
      3. gcloud auth login && gcloud auth application-default login
      4. colima start                (before first container use)
      5. claude                      then /login
      6. Open VS Code, sign in, turn on Settings Sync.
         That is what restores settings, keybindings, snippets and extensions —
         VS Code config is deliberately not in this repo.
      7. Restart iTerm2 to pick up the repo preferences folder.

    Then run ./verify.sh to confirm the machine matches the repo.
STEPS
