#!/bin/bash
#
# macOS Setup Script
# Installs prerequisites, Homebrew packages, and applies system defaults.
#
# Usage:
#   ./setup.sh          # Full setup
#   ./setup.sh defaults # Apply macOS defaults only
#   ./setup.sh brew     # Install Homebrew packages only
#

set -euo pipefail

# ──────────────────────────────────────────────────────────────────────────────
# Colors & Helpers
# ──────────────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
error() { echo -e "${RED}✗${NC}  $1"; exit 1; }

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

brew_install() {
    local type="$1"
    local name="$2"

    if [[ "$type" == "cask" ]]; then
        if ! brew list --cask --versions "$name" &>/dev/null; then
            info "Installing $name..."
            if ! brew install --cask "$name"; then
                if brew list --cask --versions "$name" &>/dev/null; then
                    success "$name already installed"
                    return
                fi
                error "Failed to install $name"
            fi
        else
            success "$name already installed"
        fi
    else
        if ! brew list "$name" &>/dev/null; then
            info "Installing $name..."
            brew install "$name"
        else
            success "$name already installed"
        fi
    fi
}

install_packages() {
    info "Installing Homebrew packages..."
    echo ""

    # Casks (GUI apps)
    brew_install cask "ghostty"
    brew_install cask "raycast"
    brew_install cask "notion"
    brew_install cask "postico"
    brew_install cask "slack"
    brew_install cask "google-chrome"
    brew_install cask "linear-linear"

    echo ""
    success "All packages installed"
}

# ──────────────────────────────────────────────────────────────────────────────
# macOS Defaults
# ──────────────────────────────────────────────────────────────────────────────

apply_defaults() {
    info "Applying macOS defaults..."

    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.3
    defaults write com.apple.dock mru-spaces -bool false
    defaults write com.apple.dock launchanim -bool false
    defaults write com.apple.dock minimize-to-application -bool true
    defaults write com.apple.dock orientation -string "left"
    defaults write com.apple.dock show-process-indicators -bool false
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock tilesize -int 32
    defaults write com.apple.dock persistent-apps -array
    defaults write com.apple.dock wvous-tl-corner -int 0
    defaults write com.apple.dock wvous-tr-corner -int 0
    defaults write com.apple.dock wvous-bl-corner -int 0
    defaults write com.apple.dock wvous-br-corner -int 0

    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder QuitMenuItem -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder CreateDesktop -bool false
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write com.apple.finder AppleShowAllExtensions -bool true
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder ShowRecentTags -bool false

    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 10
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write NSGlobalDomain AppleICUForce24HourTime -bool true
    defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
    defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"
    defaults write NSGlobalDomain AppleMetricUnits -int 1
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    defaults write NSGlobalDomain AppleReduceDesktopTinting -bool true
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

    defaults write com.apple.screencapture location -string "$HOME/Desktop"
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture disable-shadow -bool true
    defaults write com.apple.screencapture show-thumbnail -bool false

    defaults write com.apple.ActivityMonitor ShowCategory -int 0
    defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    defaults write com.apple.ActivityMonitor SortDirection -int 0

    defaults write com.apple.TextEdit RichText -bool false
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    defaults write com.apple.LaunchServices LSQuarantine -bool false

    defaults write com.apple.CrashReporter DialogType -string "none"

    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    info "Restarting Dock and Finder..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true

    success "macOS defaults applied"
}

# ──────────────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────────────

main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║      macOS Setup Script                ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    case "${1:-full}" in
        defaults)
            apply_defaults
            ;;
        brew)
            install_homebrew
            install_packages
            ;;
        full|*)
            install_prerequisites
            install_homebrew
            install_packages
            echo ""
            apply_defaults
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
    echo "  2. Apply Home Manager configuration:"
    echo "     nix run home-manager -- switch --flake ~/dotfiles"
    echo ""
}

main "$@"
