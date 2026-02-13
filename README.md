# Dotfiles

My Nix + Home Manager development environment.

## Setup

### 1. Install Nix (via Determinate Systems installer)
https://docs.determinate.systems

### 2. Clone the repo
```bash
nix-shell -p git --run "git clone https://github.com/hushiooo/dotfiles.git ~/dotfiles"
```

### 3. Bootstrap macOS apps and defaults
```bash
cd ~/dotfiles && ./setup.sh
```

### 4. Apply Home Manager configuration
```bash
nix run home-manager -- switch --flake ~/dotfiles
```

## SSH and GPG keys

```bash
# SSH key
ssh-keygen -t ed25519 -C "YOUR_EMAIL"
eval "$(ssh-agent)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
pbcopy < ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings -> SSH and GPG keys

# GPG key
gpg --full-generate-key
gpg --list-secret-keys --keyid-format=long
gpg --armor --export YOUR_EMAIL | pbcopy

# Add to GitHub: Settings -> SSH and GPG keys

# Verify
ssh -T git@github.com
echo "test" | gpg --clearsign
```

## Daily commands

```bash
# Rebuild after config changes
home-manager switch --flake ~/dotfiles

# Update flake inputs
nix flake update

# Clean up old generations
nix-collect-garbage -d

# Format nix files
nix fmt

# Dev shell with nix tooling
nix develop
```

## Structure

```
.
├── flake.nix
├── flake.lock
├── home.nix
├── home/           # Program modules
├── config/         # Raw config files
├── setup.sh        # macOS bootstrap script
└── README.md
```

## Troubleshooting

### "command not found: home-manager"

```bash
nix run home-manager -- switch --flake ~/dotfiles
```

### "error: flake has no lock file"

```bash
cd ~/dotfiles && nix flake update
```

### GPG signing fails

```bash
export GPG_TTY=$(tty)
gpgconf --kill gpg-agent
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options Search](https://home-manager-options.extranix.com/)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Determinate Systems Nix](https://determinate.systems/nix/)

## License

MIT
