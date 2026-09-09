# Homebrew packages — installed by `brew bundle --file=Brewfile`.
# `brew bundle` is a no-op for anything already present, so it is safe to re-run.

# No taps needed — everything below is in homebrew-core.

# --- CLI ---
brew "autojump"                  # `j <dir>` jump, sourced by config.fish
brew "docker"                    # CLI only — needs a runtime, see colima below
brew "colima"                    # ADDED: container runtime providing the docker socket
brew "fish"                      # login shell
brew "gh"
brew "mise"                      # runtime version manager (node etc.), replaced fnm
brew "postgresql@17"
brew "starship"                  # prompt
brew "yarn"

# --- Required: the environment is not usable without these ---
cask "iterm2"
cask "visual-studio-code"
cask "font-fira-code-nerd-font"  # iTerm profile wants "FiraCodeNFM-Reg 13"
cask "gcloud-cli"                # installs under /opt/homebrew/share/google-cloud-sdk
cask "google-chrome"

# --- Recommended ---
cask "1password"
cask "1password-cli"
cask "claude"                    # Claude desktop app (the CLI is installed separately)
cask "raycast"
cask "bruno"

# --- Optional: uncomment as wanted ---
# cask "spotify"
# cask "notion"
# cask "telegram"
# cask "whatsapp"
# cask "fantastical"
# cask "monitorcontrol"
# cask "bartender"
# cask "sunsama"
# cask "superhuman"
#
# Not available via brew (Mac App Store only — install by hand or via `mas`):
# Amphetamine, Numbers, Pages
