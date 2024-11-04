# Nix Configuration

This repository contains my personal system configuration files.
I use Nix (with nix-darwin as I'm on macOS) to manage my environment in a declarative, reproducible and version-controlled way.

## Initial Setup

Reset your machine from scratch and do not use FileVault disk encryption (useless on a mac M2+ anyway).

### 1. Prerequisites
```bash
# Install xcode cli tools
xcode-select --install

# Install rosetta
sudo softwareupdate --install-rosetta --agree-to-license

# Install homebrew
sh <(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)
```

### 2. Install Nix Package Manager
```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 3. Clone Configuration
```bash
nix-shell -p git --run 'git clone https://github.com/hushiooo/dotfiles.git ~/dotfiles'
```

### 4. Install Nix-Darwin and Apply Configuration
```bash
nix run nix-darwin \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake ~/dotfiles#prime --show-trace
```

### 5. Verify Installation
```bash
# Check nix-darwin version
darwin-rebuild --version

# Verify system configuration
darwin-rebuild check
```

### 6. Configure SSH and GPG (Optional)
```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "hushio@proton.me"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

# → Paste in GitHub Settings → SSH Keys

# 2. Generate GPG key
gpg --full-generate-key # Choose RSA 4096 + no expiration
gpg --list-secret-keys --keyid-format=long # >> sec rsa4096/YOUR_KEY_ID
gpg --armor --export hushio@proton.me | pbcopy

# → Paste in GitHub Settings → GPG Keys

# 3. Test
ssh -T git@github.com
echo "test" | gpg --clearsign
```

## Lifecycle

### Maintenance
```bash
# Rebuild system with latest changes
darwin-rebuild switch --flake ~/dotfiles#prime

# Update flake dependencies
nix flake update
```

### Create New Configuration
```bash
# Initialize new flake
nix flake init -t nix-darwin \
  --extra-experimental-features "nix-command flakes"

# Build configuration
darwin-rebuild build --flake ~/dotfiles#<FLAKE_CONFIG_NAME>

# Apply configuration
darwin-rebuild switch --flake ~/dotfiles#<FLAKE_CONFIG_NAME>
```

## Repository Structure
```bash
├── README.MD
└── nix
    ├── flake.lock   # Flake lockfile
    ├── flake.nix    # Flake config file
    ├── home.nix     # Home-manager config file
    ├── home/        # Home-manager programs config files
    └── config/      # Other programs config files
```

## Additional Resources
- [Nix-Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Home-Manager Documentation](https://nix-community.github.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Packages](https://search.nixos.org/packages)
- [Nix-Darwin configuration options](https://daiderd.com/nix-darwin/manual/index.html)

## License

MIT License
