#!/bin/bash
#
# Check that this machine matches the repo. Read-only — changes nothing.
# Exits 0 if everything lines up, 1 if anything is missing or has drifted.
#
#   ./verify.sh            check everything
#   ./verify.sh --quiet    only print problems
#
# Honours $HOME, so it can be pointed at a test home directory:
#   HOME=/tmp/fakehome ./verify.sh

set -uo pipefail   # deliberately no -e: we want to run every check and total up

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_SRC="$REPO/home"
BREW_PREFIX="/opt/homebrew"

QUIET=0
[ "${1:-}" = "--quiet" ] && QUIET=1

PASS=0
FAIL=0

if [ -t 1 ]; then
  BOLD=$(printf '\033[1m'); DIM=$(printf '\033[2m'); RED=$(printf '\033[31m')
  GREEN=$(printf '\033[32m'); RESET=$(printf '\033[0m')
else
  BOLD=""; DIM=""; RED=""; GREEN=""; RESET=""
fi

stage() { printf '\n%s==> %s%s\n' "$BOLD" "$1" "$RESET"; }

pass() {
  PASS=$((PASS + 1))
  [ "$QUIET" -eq 1 ] || printf '    %s✓%s %s\n' "$GREEN" "$RESET" "$1"
}

fail() {
  FAIL=$((FAIL + 1))
  # Colours are passed as separate printf arguments rather than interpolated
  # next to literal text: "$DIM— " made bash read the em dash's first byte as
  # part of the variable name, which is fatal under `set -u`.
  if [ -n "${2:-}" ]; then
    printf '    %s✗%s %s %s— %s%s\n' "$RED" "$RESET" "$1" "$DIM" "$2" "$RESET"
  else
    printf '    %s✗%s %s\n' "$RED" "$RESET" "$1"
  fi
}

# ---------------------------------------------------------------- symlinks ---

stage "Symlinks"

LINK_LIST="$(mktemp -t env-verify)"
( cd "$HOME_SRC" && find . -type f ! -name '.DS_Store' -print ) \
  | sed 's|^\./||' | sort > "$LINK_LIST"

while IFS= read -r rel; do
  src="$HOME_SRC/$rel"
  dst="$HOME/$rel"
  if [ ! -e "$dst" ] && [ ! -L "$dst" ]; then
    fail "~/$rel" "missing"
  elif [ ! -L "$dst" ]; then
    fail "~/$rel" "real file, not a link to the repo"
  elif [ "$(readlink "$dst")" != "$src" ]; then
    fail "~/$rel" "links to $(readlink "$dst")"
  else
    pass "~/$rel"
  fi
done < "$LINK_LIST"
rm -f "$LINK_LIST"

# ------------------------------------------------------------------ brew ----

stage "Homebrew packages"

if ! command -v brew >/dev/null 2>&1; then
  fail "brew" "not installed"
else
  pass "brew $(brew --version | head -1 | awk '{print $2}')"

  INSTALLED_F="$(mktemp -t env-formulae)"
  INSTALLED_C="$(mktemp -t env-casks)"
  brew list --formula -1 2>/dev/null | sort > "$INSTALLED_F"
  brew list --cask -1 2>/dev/null | sort > "$INSTALLED_C"

  # Pull uncommented brew "..." / cask "..." names out of the Brewfile.
  # A tapped formula written owner/tap/name is listed by brew as just "name", so
  # compare on the last path segment. Nothing is tapped today, but this keeps the
  # check correct if a tapped formula is added later.
  while IFS= read -r line; do
    case "$line" in
      brew\ \"*)
        name=$(printf '%s' "$line" | sed -e 's/^brew "//' -e 's/".*$//')
        base=${name##*/}
        if grep -qxF "$base" "$INSTALLED_F"; then pass "$name"; else fail "$name" "not installed"; fi
        ;;
      cask\ \"*)
        name=$(printf '%s' "$line" | sed -e 's/^cask "//' -e 's/".*$//')
        if grep -qxF "$name" "$INSTALLED_C"; then pass "cask $name"; else fail "cask $name" "not installed"; fi
        ;;
    esac
  done < "$REPO/Brewfile"

  rm -f "$INSTALLED_F" "$INSTALLED_C"
fi

# ------------------------------------------------------------------ node ----

stage "Runtimes (mise)"

MISE_CONFIG="$HOME_SRC/.config/mise/config.toml"

if ! command -v mise >/dev/null 2>&1; then
  fail "mise" "not installed"
else
  pass "mise $(mise --version 2>/dev/null | awk '{print $1}')"

  INSTALLED_T="$(mktemp -t env-mise)"
  mise ls --installed 2>/dev/null > "$INSTALLED_T"

  # Read the tool names out of the committed [tools] table. Keys may be bare
  # (node) or quoted with a backend prefix ("npm:typescript").
  while IFS= read -r tool; do
    if grep -q "$tool" "$INSTALLED_T"; then
      pass "mise $tool"
    else
      fail "mise $tool" "declared in config.toml but not installed"
    fi
  done < <(sed -n '/^\[tools\]/,/^\[/p' "$MISE_CONFIG" \
             | sed -n 's/^"\{0,1\}\([^" =]*\)"\{0,1\}[[:space:]]*=.*/\1/p')

  rm -f "$INSTALLED_T"

  # The tools are only usable if activation puts them on PATH.
  for bin in node tsc typescript-language-server; do
    if mise exec -- command -v "$bin" >/dev/null 2>&1; then
      pass "$bin resolves through mise"
    else
      fail "$bin" "not resolvable via mise exec"
    fi
  done
fi

# ----------------------------------------------------------------- tools ----

stage "Tools and shell"

if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
  pass "claude installed"
else
  fail "claude" "not installed"
fi

# Directory Services, not $SHELL: $SHELL describes whichever process invoked
# this script, so it reports /bin/zsh under most tooling even when fish is the
# real login shell.
LOGIN_SHELL="$(dscl . -read "/Users/$(id -un)" UserShell 2>/dev/null | awk '{print $2}')"
[ -n "$LOGIN_SHELL" ] || LOGIN_SHELL="${SHELL:-unset}"

if [ "$LOGIN_SHELL" = "$BREW_PREFIX/bin/fish" ]; then
  pass "fish is the login shell"
else
  fail "login shell" "$LOGIN_SHELL, expected $BREW_PREFIX/bin/fish"
fi

# The cask drops these into ~/Library/Fonts.
if ls "$HOME/Library/Fonts"/FiraCodeNerdFont* >/dev/null 2>&1; then
  pass "Fira Code Nerd Font installed"
else
  fail "Fira Code Nerd Font" "not in ~/Library/Fonts"
fi

# ---------------------------------------------------------------- iterm2 ----

stage "iTerm2 preferences"

ITERM_FOLDER="$(defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true)"
ITERM_FLAG="$(defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true)"

if [ "$ITERM_FOLDER" = "$REPO/iterm2" ]; then
  pass "prefs folder points at the repo"
else
  fail "prefs folder" "${ITERM_FOLDER:-unset}, expected $REPO/iterm2"
fi

if [ "$ITERM_FLAG" = "1" ]; then
  pass "loading prefs from the custom folder"
else
  fail "LoadPrefsFromCustomFolder" "${ITERM_FLAG:-unset}, expected 1"
fi

if [ -f "$REPO/iterm2/com.googlecode.iterm2.plist" ]; then
  if plutil -lint "$REPO/iterm2/com.googlecode.iterm2.plist" >/dev/null 2>&1; then
    pass "committed plist is valid"
  else
    fail "committed plist" "malformed"
  fi
else
  fail "committed plist" "missing"
fi

# ----------------------------------------------------------------- total ----

printf '\n'
if [ "$FAIL" -eq 0 ]; then
  printf '%s%s checks passed.%s\n' "$GREEN" "$PASS" "$RESET"
  exit 0
fi

printf '%s%s failed%s, %s passed.\n' "$RED" "$FAIL" "$RESET" "$PASS"
printf 'Run ./install.sh to fix links and packages; see README for manual steps.\n'
exit 1
