# Nix Configuration

This repository contains my personal Nix configuration files.
I use nix-darwin in combination with home-manager to have a declarative, reproducible and version-controlled system configuration.

## Initial Setup

- Reset mac from scratch and do not use FileVault disk encryption.
- Have battery (50% +) and good internet connection.

### 1. Prerequisites
```bash
# Install xcode cli tools
xcode-select --install

# Install rosetta
sudo softwareupdate --install-rosetta --agree-to-license

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  -- switch --flake ~/dotfiles/nix#prime --show-trace
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
ssh-add ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

# → Paste in GitHub Settings → SSH Keys

# 2. Generate GPG key
gpg --full-generate-key # Choose: RSA (4096) + no expiration for personal use
gpg --list-secret-keys --keyid-format=long
gpg --armor --export hushio@proton.me | pbcopy

# → Paste in GitHub Settings → GPG Keys

# 3. Configure git
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true

# 4. Test
ssh -T git@github.com
git commit -S -m "test signed commit"
```

## Lifecycle

### Maintenance
```bash
# Rebuild system with latest changes
darwin-rebuild switch --flake ~/dotfiles/nix#prime

# Update flake dependencies
nix flake update
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
```bash
├── README.MD
└── nix
    ├── flake.lock   # Flake lockfile
    ├── flake.nix    # Flake config file
    ├── home.nix     # Home-manager config file
    └── home/        # Home-manager programs config files
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
