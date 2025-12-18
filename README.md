# Dotfiles

Lightweight **Nix + Home Manager** configuration for macOS.

> Terminal-centric development environment with Neovim, tmux, and modern CLI tools.

## What You Get

| Category         | Tools                                                     |
|------------------|-----------------------------------------------------------|
| **Shell**        | zsh + oh-my-posh + syntax highlighting + autosuggestions  |
| **Editor**       | Neovim with LSP, completion, debugging, treesitter        |
| **Multiplexer**  | tmux with vim-like navigation, session persistence        |
| **Navigation**   | fzf, zoxide, yazi, eza                                    |
| **Git**          | lazygit, delta diffs, GPG signing                         |
| **Monitoring**   | bottom, fastfetch                                         |
| **Theme**        | Tokyo Night everywhere                                    |

---

## Quick Start

### Fresh Install

```bash
# 1. Install Nix (Determinate Systems installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Restart terminal, then clone dotfiles
nix-shell -p git --run "git clone https://github.com/hushiooo/dotfiles.git ~/dotfiles"

# 3. Run setup script (Homebrew, GUI apps, macOS defaults)
cd ~/dotfiles && ./setup.sh

# 4. Apply Home Manager configuration
nix run home-manager -- switch --flake ~/dotfiles
```

---

## Migration Guide

### Before Reset: Backup Keys

```bash
# Quick backup (creates timestamped folder)
./setup.sh backup

# Or manual backup
mkdir -p ~/keys-backup
cp -r ~/.ssh ~/keys-backup/
gpg --export-secret-keys --armor > ~/keys-backup/gpg-private.asc
gpg --export-ownertrust > ~/keys-backup/gpg-trust.txt
```

### After Reset: Restore Keys

```bash
# SSH
mkdir -p ~/.ssh
cp -r ~/keys-backup/ssh/* ~/.ssh/
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# GPG
gpg --import ~/keys-backup/gpg-private.asc
gpg --import-ownertrust ~/keys-backup/gpg-trust.txt
gpg --edit-key YOUR_EMAIL  # Then: trust → 5 → quit

# Verify
ssh -T git@github.com
echo "test" | gpg --clearsign
```

---

## Daily Usage

```bash
# Rebuild after config changes
hms # Alias for: home-manager switch --flake ~/dotfiles

# Update all flake inputs
nix flake update ~/dotfiles

# Garbage collect old generations
nix-collect-garbage -d

# Format nix files
nix fmt

# Enter dev shell (has nix tools)
nix develop
```

---

## Keybindings

### tmux

| Key                    | Action                                 |
|------------------------|----------------------------------------|
| `C-a`                  | Prefix (instead of C-b)                |
| `C-a c`                | New window                             |
| `C-a )`                | Split horizontal                       |
| `C-a -`                | Split vertical                         |
| `C-a h/j/k/l`          | Navigate panes (vim-style)             |
| `C-a H/J/K/L`          | Resize panes                           |
| `C-a C-a`              | Toggle last window                     |
| `C-a &/é/"/'/(...`     | Jump to window 1-5 (AZERTY)            |
| `C-a x`                | Kill pane                              |
| `C-a X`                | Kill window                            |
| `C-a r`                | Reload config                          |
| `C-h/j/k/l`            | Navigate between vim/tmux seamlessly   |

### Neovim — General

| Key            | Action                   |
|----------------|--------------------------|
| `Space`        | Leader key               |
| `<leader>w`    | Save file                |
| `<leader>q`    | Quit                     |
| `<leader>b`    | Toggle previous buffer   |
| `<leader>h`    | Clear search highlights  |
| `U`            | Redo                     |

### Neovim — Navigation

| Key            | Action                       |
|----------------|------------------------------|
| `<leader>e`    | Toggle file explorer         |
| `<leader>o`    | Focus file explorer          |
| `<leader>fe`   | Reveal current file in tree  |
| `<leader>ff`   | Find files                   |
| `<leader>fg`   | Live grep                    |
| `<leader>fb`   | Find buffers                 |
| `<leader>fr`   | Recent files                 |
| `<leader>fh`   | Help tags                    |
| `<leader>fs`   | Search word under cursor     |

### Neovim — LSP

| Key            | Action                     |
|----------------|----------------------------|
| `gd`           | Go to definition           |
| `gD`           | Go to declaration          |
| `gi`           | Go to implementation       |
| `gr`           | Go to references           |
| `K`            | Hover documentation        |
| `<C-k>`        | Signature help             |
| `<leader>cr`   | Rename symbol              |
| `<leader>ca`   | Code actions               |
| `<leader>cf`   | Format buffer              |
| `<leader>ct`   | Type definition            |
| `<leader>cd`   | Show diagnostics (float)   |
| `<leader>xd`   | Diagnostics (buffer)       |
| `<leader>xD`   | Diagnostics (workspace)    |

### Neovim — Search & Replace (Spectre)

| Key            | Action                           |
|----------------|----------------------------------|
| `<leader>sr`   | Search and replace (project)     |
| `<leader>sw`   | Search word under cursor         |
| `<leader>sf`   | Search current file              |
| `dd`           | Toggle current item (in Spectre) |
| `gr`           | Replace current line             |
| `gR`           | Replace all                      |
| `Q`            | Send results to quickfix         |

### Neovim — Debugging (DAP)

**Session Control**

| Key            | Action             |
|----------------|--------------------|
| `<leader>dd`   | Start/Continue     |
| `<leader>dq`   | Stop debugging     |
| `<leader>dr`   | Restart session    |
| `<leader>dR`   | Run last session   |
| `<leader>dp`   | Pause              |

**Breakpoints**

| Key            | Action                   |
|----------------|--------------------------|
| `<leader>db`   | Toggle breakpoint        |
| `<leader>dB`   | Conditional breakpoint   |
| `<leader>dl`   | Logpoint (prints msg)    |
| `<leader>dx`   | Clear all breakpoints    |

**Stepping & Navigation**

| Key            | Action            |
|----------------|-------------------|
| `<leader>do`   | Step over         |
| `<leader>di`   | Step into         |
| `<leader>dO`   | Step out          |
| `<leader>dc`   | Run to cursor     |
| `<leader>dj`   | Go down in stack  |
| `<leader>dk`   | Go up in stack    |

**UI & Evaluation**

| Key            | Action                 |
|----------------|------------------------|
| `<leader>du`   | Toggle DAP UI          |
| `<leader>de`   | Eval expression        |
| `<leader>dE`   | Eval input expression  |
| `<leader>df`   | Float scopes panel     |
| `<leader>dw`   | Float watches panel    |
| `<leader>dh`   | Hover variable         |

**Python/Pytest**

| Key            | Action               |
|----------------|----------------------|
| `<leader>dtn`  | Debug nearest test   |
| `<leader>dtc`  | Debug test class     |
| `<leader>ds`   | Debug selection (v)  |

**Telescope Integration**

| Key            | Action               |
|----------------|----------------------|
| `<leader>dTb`  | List breakpoints     |
| `<leader>dTc`  | List configurations  |
| `<leader>dTf`  | List frames          |
| `<leader>dTv`  | List variables       |

### Neovim — Quickfix

| Key            | Action               |
|----------------|----------------------|
| `<leader>qo`   | Open quickfix        |
| `<leader>cq`   | Clear quickfix list  |

### Shell Aliases

| Alias   | Command                            |
|---------|------------------------------------|
| `hms`   | Rebuild home-manager               |
| `hmu`   | Update flake + rebuild             |
| `ll`    | `eza -alh --git`                   |
| `lt`    | `eza --tree --level=2`             |
| `gs`    | `git status -sb`                   |
| `gl`    | Pretty git log                     |
| `lg`    | lazygit                            |
| `t`     | tmux                               |
| `tn`    | New tmux session (named after dir) |
| `cat`   | bat                                |
| `cd`    | zoxide (smart cd)                  |
| `lzd`   | lazydocker                         |

---

## Structure

```
.
├── flake.nix           # Flake definition + dev shell
├── flake.lock          # Locked dependencies
├── home.nix            # Home Manager entry point
├── home/               # Program modules
│   ├── zsh.nix         # Shell configuration
│   ├── neovim.nix      # Editor + LSPs
│   ├── tmux.nix        # Multiplexer
│   ├── git.nix         # Git + delta
│   └── ...             # Other tools
├── config/             # Raw config files
│   ├── ghostty/        # Terminal emulator
│   └── nvim/           # Neovim lua config
├── setup.sh            # macOS bootstrap script
└── README.md
```

## What's Managed Where

| Component                                    | Managed By                   |
|----------------------------------------------|------------------------------|
| CLI tools, LSPs, languages                   | Nix (`home.packages`)        |
| Shell, editor, git config                    | Home Manager (`programs.*`)  |
| GUI apps (Ghostty, Docker, Raycast, Linear)  | Homebrew (`setup.sh`)        |
| macOS system defaults                        | Shell script (`setup.sh`)    |

---

## Troubleshooting

### "command not found: home-manager"

After first install, run with:

```bash
nix run home-manager -- switch --flake ~/dotfiles
```

After that, `home-manager` will be in your PATH.

### "error: flake has no lock file"

```bash
cd ~/dotfiles && nix flake update
```

### "dirty git tree" warning

This is normal — Nix warns when uncommitted changes exist. Commit or stage your changes:

```bash
git add -A
```

### GPG signing fails

```bash
export GPG_TTY=$(tty)
gpgconf --kill gpg-agent
```

### Homebrew not found after setup

Restart your terminal, or run:

```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### Slow shell startup

Check what's slow:

```bash
time zsh -i -c exit
```

Profile with:

```bash
zsh -xv 2>&1 | ts -i "%.s" | head -50
```

---

## Customization

### Adding packages

Edit `home.nix`:

```nix
home.packages = with pkgs; [
  # Add your package here
  neofetch
];
```

### Adding a new program module

1. Create `home/myprogram.nix`:

```nix
{
  enable = true;
  # ... configuration
}
```

2. Import in `home.nix`:

```nix
programs = {
  myprogram = import ./home/myprogram.nix { };
};
```

### Changing shell aliases

Edit `home/zsh.nix` → `shellAliases`.

---

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options Search](https://home-manager-options.extranix.com/)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Determinate Systems Nix](https://determinate.systems/nix/)

---

## License

MIT
