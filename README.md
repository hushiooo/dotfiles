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

## Scope

Nix + Home Manager is the default for everything: CLI tools, language
toolchains, cloud and IaC tooling, configured TUIs, shell, and fonts.

Homebrew (via `setup.sh`) is the exception, used only for:

- GUI apps, which Nix does not manage well on macOS — the `CASKS` array.
- The handful of formulae that cannot or should not come from nixpkgs. Each one
  carries its reason inline in `FORMULAE` / `HEAD_FORMULAE`: a build that OOMs
  on macOS, an unfree license we would rather not pin, or a release cadence far
  ahead of `nixpkgs-unstable`.

If you are adding a package, it goes in `home.nix` unless one of those reasons
applies.

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

## Pi coding agent

[Pi](https://pi.dev) is the terminal coding agent. Installed via Homebrew
(`setup.sh`) because it releases far faster than `nixpkgs-unstable`.

```bash
pi          # new session; run /login once to authenticate with Anthropic
pic         # continue last session
pir         # browse past sessions
```

Config lives in `config/pi/agent/`:

- `AGENTS.md` is symlinked to `~/.pi/agent/AGENTS.md` and loaded in every project.
- `settings.json` is **seeded, not symlinked** — pi rewrites it whenever you switch
  models. To reset it to the tracked version: `rm ~/.pi/agent/settings.json && hms`.

Skills are picked up automatically from `~/.agents/skills/` and per-project
`.agents/skills/`, and are callable as `/skill:name`.

## Structure

```
.
├── flake.nix
├── flake.lock
├── home.nix
├── home/           # One Home Manager module per program, listed in home.nix imports
├── config/         # Raw config files (nvim, ghostty, pi)
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
