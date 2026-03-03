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

## Cursor CLI global setup

This repository manages global Cursor CLI defaults via Home Manager:

- `~/.cursor/mcp.json` from `config/cursor/mcp.json`
- `~/.cursor/skills/*` from `config/cursor/skills/`
- `~/.cursor/commands/*` from `config/cursor/commands/`
- `~/.cursor/rules/*` from `config/cursor/rules/`
- `~/AGENTS.md` from `config/cursor/AGENTS.md`

Global agent policy includes commit hygiene: prefer atomic commits and split large changes by concern for easier human review and cherry-picking.

Included global MCP servers:

- Official reference servers (`modelcontextprotocol/servers`):
  - `fetch` (web content fetching and markdown conversion)
  - `filesystem` (secure file operations)
  - `git` (Git repository tooling)
  - `memory` (persistent knowledge graph memory)
  - `sequential-thinking` (structured reflective reasoning)
  - `time` (time and timezone conversion)
  - `everything` is intentionally excluded to keep tool surface focused
- Additional practical servers:
  - `context7` (live docs and library references)
  - `linear` (issues and project tracking)

`filesystem` is intentionally scoped to:
- `/Users/joad.goutal`

Included global skills:

- `code-review`
- `self-review`
- `commit-message`
- `test-plan`
- `debug-root-cause`
- `pr-summary`
- `preflight-checks`

Included global slash commands:

- `/self-review`
- `/test-plan`
- `/commit-message`
- `/pr-summary`
- `/preflight`
- `/mcp-status`
- `/mcp-doctor`
- `/mcp-reference`
- `/review-ready`
- `/commit-plan`

After editing any Cursor files in this repo, apply:

```bash
home-manager switch --flake ~/dotfiles
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
├── config/         # Raw config files (nvim, ghostty, cursor, ...)
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
