# System Configuration

This repository contains my system configuration files.

I use Nix to manage my environment in a declarative and reproducible way.

## Initial Setup

### 1. Prerequisites

```bash
# Install xcode cli tools
xcode-select --install

# Install rosetta
sudo softwareupdate --install-rosetta --agree-to-license

# Install homebrew (necessary for some casks)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Nix Package Manager

```bash
sh <(curl -L https://nixos.org/nix/install)
```

### 3. Clone Configuration

```bash
nix-shell -p git --run 'git clone https://github.com/hushiooo/dotfiles.git ~/dotfiles/'
```

### 4. Install Nix-Darwin and Apply Configuration

```bash
nix run nix-darwin \
  --extra-experimental-features 'nix-command flakes' \
  -- switch --flake .#${FLAKE_NAME} --show-trace
```

### 5. Configure SSH and GPG (Optional)

```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "YOUR_EMAIL"
eval "$(ssh-agent)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

# → Paste in GitHub Settings → SSH Keys

# 2. Generate GPG key
gpg --full-generate-key # Choose RSA 4096 + no expiration
gpg --list-secret-keys --keyid-format=long # >> sec rsa4096/YOUR_KEY_ID
gpg --armor --export YOUR_EMAIL | pbcopy

# → Paste in GitHub Settings → GPG Keys

# 3. Test
ssh -T git@github.com
echo "test" | gpg --clearsign

# 4. Set ssh as remote url
git remote set-url origin git@github.com:hushiooo/dotfiles.git
```

## Update config

Make sure the changes are at least added to the git worktree.

```bash
# Rebuild system with latest changes
sudo darwin-rebuild switch --flake . --show-trace

# Update flake dependencies
nix flake update
```

## Useful commands

```bash
nix-collect-garbage -d
```

## Repository Structure

```bash
.
├── home/        # Home manager programs config files
├── config/      # Other programs config files
├── system/      # System config files
├── home.nix     # Home manager config
├── flake.nix    # Nix flake config
└── flake.lock   # Flake lockfile

```

## Additional Resources

- [NixOS Documentation](https://nixos.org/)
- [NixOS Packages](https://search.nixos.org/packages)
- [Home-Manager Documentation](https://nix-community.github.io/home-manager/)
- [Home-Manager Options Search](https://home-manager-options.extranix.com/)
- [Nix-Darwin Documentation](https://github.com/LnL7/nix-darwin)
- [Nix-Darwin Options](https://daiderd.com/nix-darwin/manual/index.html)
- [Vimjoyer YT Channel](https://www.youtube.com/@vimjoyer)

## License

MIT License.
