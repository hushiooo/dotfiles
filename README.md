# Dotfiles

My Nix + Home Manager development environment.

## Setup

On a fresh Mac, one command does everything: Xcode CLI tools, Rosetta, clone to
`~/dev/dotfiles`, Nix (Determinate installer), Homebrew + `Brewfile`, the first
Home Manager switch (which also applies macOS defaults) and the git hooks.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hushiooo/dotfiles/main/setup.sh)
```

It is safe to re-run from the checkout (`./setup.sh`), and `./setup.sh brew`
only syncs Homebrew packages.

## Scope

Nix + Home Manager is the default for everything: CLI tools, language
toolchains, cloud and IaC tooling, configured TUIs, shell, and fonts.

Homebrew (the `Brewfile`, applied by `./setup.sh brew`) is the exception, used
only for:

- GUI apps that nixpkgs does not ship for macOS — the `cask` entries.
- The handful of formulae that cannot or should not come from nixpkgs. Each one
  carries its reason inline: a build that OOMs on macOS, a bottle that 404s, or
  a release cadence far ahead of `nixpkgs-unstable`.

If you are adding a package, it goes in `home/packages.nix` (or the program's
own module in `home/`) unless one of those reasons applies.

Configs in `config/` for nvim, ghostty and pi are live symlinks into this
checkout (`mkOutOfStoreSymlink`), so edits apply without a rebuild. This relies
on the repo living at `~/dev/dotfiles` (set in `flake.nix`).

macOS defaults (Dock, Finder, keyboard, screenshots, ...) live in
`home/macos.nix` and are re-applied on every switch; Dock and Finder restart
only when those settings change. Note that this includes an empty Dock
(`persistent-apps = [ ]`), so apps pinned by hand are removed on the next switch.

## SSH and GPG keys

```bash
# SSH key (held by the macOS ssh-agent + Keychain; gpg-agent is GPG-only)
ssh-keygen -t ed25519 -C "YOUR_EMAIL"
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
# Rebuild after config changes (nh home switch, shows a package diff)
hms

# Update inputs, review the diff and confirm, then commit flake.lock
hmu

# Roll back to the previous generation (repeat to go further back)
hmr

# Clean up old generations (also runs weekly via launchd)
nxgc

# Run any nixpkgs tool once without installing it
, cowsay hello

# Format nix, lua, js and json files
nix fmt

# Build the config and run lint + format checks
nix flake check

# Dev shell with nix tooling (stays in zsh, thanks to nix-your-shell)
nix develop
```

Git hooks (`.pre-commit-config.yaml`, run by `prek`) scan staged changes for
secrets with gitleaks and run treefmt, statix, deadnix and shellcheck. They are
installed by `setup.sh`; on an existing checkout run `prek install` once.

## Workflows

### Edit a config

- **nvim, ghostty, pi** (`config/`): live symlinks, so save and you are done.
  Restart nvim, or reload Ghostty with `super+shift+,`.
- **Everything else** (`home/*.nix`): edit, then `hms`.

### Add a CLI tool

1. Try it first without installing anything: `, <tool>`.
2. If it has a Home Manager module (search the
   [options](https://home-manager-options.extranix.com/)), enable it in its own
   `home/<tool>.nix`. Otherwise add it to `home/packages.nix`.
3. Run `hms`.

### Add a module

1. Create `home/<name>.nix`, then add it to the `imports` in `home.nix`.
2. Run `git add home/<name>.nix` **before** `hms`. Flakes only see files git
   tracks, so an untracked module fails with "path does not exist".

### Add a GUI app or brew-only formula

1. Add a `cask "..."` (or `brew "..."` with its reason inline) to `Brewfile`.
2. Run `./setup.sh brew`.

To remove one, delete the line, then run `brew bundle cleanup --file Brewfile`
(dry run) and add `--force` to actually uninstall.

### Change a macOS default

1. Find the key: `defaults read <domain> > /tmp/before`, flip the setting in
   System Settings, then diff against a fresh `defaults read <domain>`.
2. Add the key to `home/macos.nix` and run `hms`. Dock, Finder and
   SystemUIServer restart automatically when the declared defaults change.

Removing a key from `home/macos.nix` does not revert it; run
`defaults delete <domain> <key>` once.

### Update

- `hmu`: update every input, show the package diff, ask for confirmation,
  then commit `flake.lock`.
- One input only: `nix flake update nixpkgs && hms`.
- Something broke: `hmr` to roll back right away, then `git revert` the lock
  commit (or pin the input) and `hms`.

### Before pushing

Hooks run on commit. `nix flake check` additionally builds the whole config, so
run it after larger changes.

## Secrets

This repo is public. Encrypted secrets are safe to commit (only the age key can
decrypt them), but treat it as permanent publication:

- **Good fit:** personal tokens and keys for your own tools.
- **Keep out:** work credentials, and anything whose leak would be serious or
  hard to rotate (cloud root keys, production credentials). If the age key ever
  leaks, every secret in the git history is exposed, so put those in the
  password manager or a private repo.
- **Values are encrypted, key names are not.** `aws_prod_key: ENC[...]` still
  says what you hold, so prefer neutral names.

[sops-nix](https://github.com/Mic92/sops-nix) is wired in (`home/sops.nix`) but
does nothing until a secret is declared. At activation, secrets are decrypted
into a per-user temporary directory, never into the Nix store.

### First-time setup

```bash
# 1. Create the age key and back it up in your password manager.
#    Losing it means losing access to every secret encrypted with it.
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# 2. Point sops at your public key (the "# public key:" line of keys.txt).
cat > .sops.yaml <<EOF
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: $(age-keygen -y ~/.config/sops/age/keys.txt)
EOF

# 3. Create and edit the encrypted file (opens $EDITOR).
mkdir -p secrets && sops secrets/secrets.yaml
```

### Declare and use a secret

Declare it in `home/sops.nix`:

```nix
sops = {
  defaultSopsFile = ../secrets/secrets.yaml;
  secrets.github_token = { };
};
```

Then use its decrypted path, never its value, so it stays out of the store:

```nix
# A shell variable (home/zsh.nix initContent)
''export GITHUB_TOKEN="$(< ${config.sops.secrets.github_token.path})"''

# A whole config file with the secret inlined
sops.templates."foo/config.toml".content = ''
  token = "${config.sops.placeholder.github_token}"
'';
# then: xdg.configFile."foo/config.toml".source =
#   config.lib.file.mkOutOfStoreSymlink config.sops.templates."foo/config.toml".path;
```

### Day to day

```bash
sops secrets/secrets.yaml    # edit (decrypts in $EDITOR, re-encrypts on save)
hms                          # apply
```

### New machine

Restore `~/.config/sops/age/keys.txt` from the password manager **before**
running `setup.sh`, otherwise activation cannot decrypt the secrets.

### Rotate

- **A leaked secret:** revoke it at the source first (history keeps the old
  value forever), then `sops secrets/secrets.yaml` with the new value.
- **The age key:** generate a new key, replace the `age:` recipient in
  `.sops.yaml`, run `sops updatekeys secrets/secrets.yaml`, then rotate every
  secret the old key could read.

## Pi coding agent

[Pi](https://pi.dev) is the terminal coding agent. Installed via Homebrew
(`setup.sh`) because it releases far faster than `nixpkgs-unstable`.

```bash
pi          # new session; run /login once to authenticate with Anthropic
pic         # continue last session
pir         # browse past sessions
```

Config lives in `config/pi/agent/` (wired up in `home/pi.nix`):

- `AGENTS.md` and `extensions/` are live-symlinked into `~/.pi/agent/`;
  `AGENTS.md` is loaded in every project.
- `settings.json` is **seeded, not symlinked** — pi rewrites it whenever you switch
  models. To reset it to the tracked version: `rm ~/.pi/agent/settings.json && hms`.

Skills are picked up automatically from `~/.agents/skills/` and per-project
`.agents/skills/`, and are callable as `/skill:name`.

## Structure

```
.
├── flake.nix       # Inputs, home configuration, formatter, checks
├── flake.lock
├── home.nix        # Core settings; imports every module in home/
├── home/           # One Home Manager module per concern (programs, macos, nix, sops, packages)
├── config/         # Raw config files (nvim, ghostty, herdr, pi, zsh, mcp)
├── skills/         # Agent skills, linked into ~/.agents/skills
├── Brewfile        # Homebrew casks and the few brew-only formulae
├── setup.sh        # One-command macOS bootstrap
└── README.md
```

## Troubleshooting

### "command not found: home-manager"

```bash
nix run home-manager -- switch --flake ~/dev/dotfiles
```

### "error: flake has no lock file"

```bash
cd ~/dev/dotfiles && nix flake update
```

### GPG signing fails

```bash
gpgconf --kill gpg-agent
```

## Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Home Manager Options Search](https://home-manager-options.extranix.com/)
- [Nixpkgs Search](https://search.nixos.org/packages)
- [Determinate Systems Nix](https://determinate.systems/nix/)

## License

[MIT](LICENSE)
