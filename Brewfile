# Homebrew is the exception: GUI apps, plus formulae that cannot or should not
# come from nixpkgs (reason inline). Everything else goes in home/packages.nix.
# Applied by `./setup.sh brew`, i.e. `brew bundle --file Brewfile`.

# Take over apps already installed by hand instead of failing on them.
cask_args adopt: true

tap "earthbuild/tap"

brew "checkov"                                # nixpkgs build OOMs on macOS (heavy py deps)
brew "pi-coding-agent"                        # releases far faster than nixpkgs
brew "earthbuild/tap/earth", args: ["HEAD"]   # bottle 404s; build from source

cask "gcloud-cli"
cask "google-chrome"
cask "linear"
cask "notion"
cask "obsidian"
cask "orbstack"
cask "postico"
cask "raycast"
cask "session-manager-plugin"
cask "slack"
cask "tailscale-app"
cask "temurin"
