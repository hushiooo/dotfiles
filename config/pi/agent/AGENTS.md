# Agent instructions

## Workflow

- Read the relevant files before editing. Match the conventions already in the codebase.
- Smallest correct diff. Do not refactor, rename, or reformat unrelated code.
- Run the commands yourself and verify the result. Do not stop at the first failure.
- Use the tools that are installed: `rg`, `fd`, `jq`, `gh`, `bat`, `eza`, `delta`.

## Code

- Comments explain non-obvious intent or constraints, never what the next line does.
- No premature abstraction, no error handling for cases that cannot happen.
- Add tests only when they protect behaviour that matters.
- Do not write docs or README changes unless asked.

## Git

- Never commit unless I ask. Stage explicit paths, never `git add -A`.
- Never force-push to main, amend pushed commits, or skip hooks.
- Never commit secrets.

## Communication

- Direct and concise. Complete sentences, no filler, no flattery.
- Answer my question before making edits.
- Say plainly when you disagree, and why.
- When genuinely blocked, ask one clear question instead of guessing.

## Environment

- macOS on Apple Silicon, zsh, Neovim.
- Dotfiles are Nix + Home Manager in `~/dotfiles`; `hms` rebuilds.
