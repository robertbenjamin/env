# env

My development environment configurations and setup. Nice and simple, can be run with one script.

```bash
git clone git@github.com:robertbenjamin/env.git ~/Documents/Work/env
cd ~/Documents/Work/env
./install.sh          # --dry-run to see what it would do
./verify.sh           # check the machine matches the repo
```

## How it works

`home/` mirrors `$HOME`, so the directory structure _is_ the mapping — `install.sh` walks the tree
and symlinks every file it finds. Editing `~/.config/fish/config.fish` _is_ editing
`home/.config/fish/config.fish`, so `git status` always shows what has drifted.

Replaced files are moved to `~/.env-backup/<timestamp>/` first. Re-running is safe.

## What's here

- **Fish** — Git abbreviations, show/hide hidden files, `sfish` to reload, autojump, paths
- **Starship** — minimal two-line prompt with Git status
- **Claude Code** — `CLAUDE.md` and settings
- **iTerm2** — full profile, Material Palenight
- **Brewfile** — CLI tools and apps, all from homebrew-core
- **Zsh** — a fallback shell only; fish is the login shell
- **mise** — pins node plus global `typescript` / `typescript-language-server`
- **Git** — user, `autoSetupRemote`, `ff = only`, global gitignore
- **gh** — `co` alias, ssh git protocol

## Setup

`install.sh` runs six stages — `brew`, `links`, `runtimes`, `claude`, `iterm`, `shell` — any of
which can be run alone with `--only <stage>`. `runtimes` follows `links` because mise reads the
symlinked config.

Then the things that need a browser or a credential:

- `gh auth login --git-protocol ssh` — also generates and uploads the SSH key
- `gcloud auth login && gcloud auth application-default login`
- `colima start` before first container use
- `claude`, then `/login`
- VS Code — sign in, turn on Settings Sync
- Restart iTerm2 to pick up the repo prefs folder

## Deliberately not here

- **VS Code config** — Settings Sync already does it
- **`.npmrc`, `.yarnrc.yml`, `gh` hosts.yml, SSH keys** — tokens and credentials
- **`~/.ssh/config`** — `id_ed25519` is already in ssh's default identity list
- **macOS `defaults`** — still by hand, see below

## Todo

- `macos-defaults.sh` for keyboard repeat, Finder, Dock and screenshot settings
