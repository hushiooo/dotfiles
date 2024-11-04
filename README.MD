# Nix Configuration

This repository contains my personal Nix configuration files, managed with nix-darwin and home-manager.

## Initial Setup

### 1. Prerequisites
```bash
xcode-select --install
sudo softwareupdate --install-rosetta --agree-to-license
```

### 2. Install Nix Package Manager
```bash
sh <(curl -L https://nixos.org/nix/install)

# Important: After installation, restart your terminal
```

### 3. Clone Configuration
```bash
nix-shell -p git --run 'git clone https://github.com/hushiooo/dotfiles.git ~/dotfiles'
```

### 4. Install Nix-Darwin and Apply Configuration
```bash
nix run nix-darwin \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake ~/dotfiles/nix#prime
```

### 5. Initialize SSH (Optional)
```bash
ssh-init    # Generate SSH keys

ssh-restore # Restore SSH from backup
```

### 6. Initialize GPG (Optional)
```bash
gpg-init # Generate GPG keys

gpg-restore # Restore GPG from backup
```

## Lifecycle

### Verifying Installation
```bash
# Check nix-darwin version
darwin-rebuild --version

# Check home-manager version
home-manager --version

# Verify system configuration
darwin-rebuild check
```

### Maintenance
```bash
# Rebuild system with latest changes
darwin-rebuild switch --flake ~/dotfiles/nix#prime

# Update flake dependencies
nix flake update

# Update home-manager configuration
home-manager switch

# Create SSH backup
ssh-backup

# Create GPG backup
gpg-backup
```

### Create New Configuration
```bash
# Initialize new flake
nix flake init -t nix-darwin \
  --extra-experimental-features "nix-command flakes"

# Build configuration
darwin-rebuild build --flake ~/dotfiles/nix#<FLAKE_CONFIG_NAME>

# Apply configuration
darwin-rebuild switch --flake ~/dotfiles/nix#<FLAKE_CONFIG_NAME>
```

## Repository Structure
```
nix/
├── flake.nix         # Main flake configuration
├── home.nix          # Home-manager configuration
└── home/             # Home-manager modules
    └── ...           # Various configuration files
```

## Additional Resources
- [Nix-Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Home-Manager Documentation](https://nix-community.github.io/home-manager/)
- [Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [NixOS Packages](https://search.nixos.org/packages)
- [Nix-Darwin configuration options](https://daiderd.com/nix-darwin/manual/index.html)

## Contributing
Feel free to open issues or submit pull requests if you have suggestions for improvements.

## License
MIT License

Copyright (c) 2024 | hushiooo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files.
