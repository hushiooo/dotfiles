#!/bin/bash
#
# macOS bootstrap: from a fresh Mac to a fully applied config in one command.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/hushiooo/dotfiles/main/setup.sh)
#
# Installs Xcode CLI tools and Rosetta, clones this repo (if run from outside a
# checkout), installs Nix and Homebrew, applies the Brewfile, then activates the
# Home Manager configuration (which also applies macOS defaults). Safe to re-run.
#
# Usage:
#   ./setup.sh          # Full setup
#   ./setup.sh brew     # Install Homebrew packages only
#

set -euo pipefail

REPO_URL="https://github.com/hushiooo/dotfiles.git"
DOTFILES="${DOTFILES:-$HOME/dev/dotfiles}"

# ──────────────────────────────────────────────────────────────────────────────
# Colors & Helpers
# ──────────────────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }

if [[ "$(id -u)" -eq 0 ]]; then
    echo "Do not run this script with sudo."
    echo "Run: ./setup.sh ..."
    exit 1
fi

# ──────────────────────────────────────────────────────────────────────────────
# Prerequisites
# ──────────────────────────────────────────────────────────────────────────────

install_prerequisites() {
    info "Checking prerequisites..."

    # Xcode CLI tools
    if ! xcode-select -p &>/dev/null; then
        info "Installing Xcode Command Line Tools..."
        xcode-select --install
        echo ""
        warn "Press ENTER after Xcode CLI tools installation completes..."
        read -r
    else
        success "Xcode CLI tools already installed"
    fi

    # Rosetta (for Apple Silicon)
    if [[ $(uname -m) == "arm64" ]]; then
        if ! /usr/bin/pgrep -q oahd 2>/dev/null; then
            info "Installing Rosetta..."
            sudo softwareupdate --install-rosetta --agree-to-license
            success "Rosetta installed"
        else
            success "Rosetta already installed"
        fi
    fi
}

# Re-runs this script from a checkout at $DOTFILES when invoked from elsewhere
# (e.g. via curl), since the Brewfile and flake must be on disk.
ensure_checkout() {
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$here/flake.nix" ]]; then
        DOTFILES="$here"
        return
    fi
    if [[ ! -d "$DOTFILES/.git" ]]; then
        info "Cloning $REPO_URL into $DOTFILES..."
        git clone "$REPO_URL" "$DOTFILES"
    fi
    exec "$DOTFILES/setup.sh" "$@"
}

# ──────────────────────────────────────────────────────────────────────────────
# Nix
# ──────────────────────────────────────────────────────────────────────────────

install_nix() {
    if [[ ! -x /nix/var/nix/profiles/default/bin/nix ]]; then
        info "Installing Nix (Determinate Systems installer)..."
        curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
        success "Nix installed"
    else
        success "Nix already installed"
    fi
    if ! command -v nix &>/dev/null; then
        # shellcheck source=/dev/null
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
}

switch_home() {
    info "Activating the Home Manager configuration..."
    # -b: move pre-existing dotfiles aside instead of failing on them.
    nix run --inputs-from "$DOTFILES" home-manager -- switch --flake "$DOTFILES" -b hm-backup
    success "Home Manager configuration active"

    info "Installing git hooks..."
    (cd "$DOTFILES" && "$HOME/.nix-profile/bin/prek" install)
}

# ──────────────────────────────────────────────────────────────────────────────
# Homebrew
# ──────────────────────────────────────────────────────────────────────────────

install_homebrew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
        success "Homebrew installed"
    else
        success "Homebrew already installed"
    fi
}

# Homebrew refuses to load third-party taps and formulae until they are trusted.
trust_third_party() {
    local name
    awk -F'"' '/^tap /{print $2}' "$DOTFILES/Brewfile" | while read -r name; do
        brew tap "$name"
        brew trust --tap "$name" &>/dev/null || true
    done
    awk -F'"' '/^brew "[^"\/]+\/[^"\/]+\/[^"]+"/{print $2}' "$DOTFILES/Brewfile" | while read -r name; do
        brew trust --formula "$name" &>/dev/null || true
    done
}

install_packages() {
    trust_third_party
    info "Installing Homebrew packages from $DOTFILES/Brewfile..."
    brew bundle --file="$DOTFILES/Brewfile"
    success "All Homebrew packages installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

usage() {
    echo "Usage: $0 [full|brew]"
}

main() {
    case "${1:-full}" in
        full | brew) ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            exit 1
            ;;
    esac

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║      macOS Setup Script                ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    case "${1:-full}" in
        brew)
            ensure_checkout "$@"
            install_homebrew
            install_packages
            ;;
        full)
            install_prerequisites
            ensure_checkout "$@"
            install_nix
            install_homebrew
            install_packages
            switch_home
            ;;
    esac

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║      Setup Complete!                   ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Remap Caps Lock → Escape:"
    echo "     System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys"
    echo ""
    echo "  2. Open a new terminal. From now on, rebuild with: hms"
    echo ""
}

main "$@"
