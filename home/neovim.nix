{ pkgs, ... }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    cmp-buffer
    cmp-nvim-lsp
    cmp-path
    cmp_luasnip
    dressing-nvim
    gitsigns-nvim
    lualine-nvim
    luasnip
    nvim-cmp
    nvim-lspconfig
    nvim-spectre
    nvim-web-devicons
    plenary-nvim
    telescope-file-browser-nvim
    telescope-fzf-native-nvim
    telescope-nvim
    tokyonight-nvim
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        bash
        go
        hcl
        javascript
        json
        lua
        markdown
        nix
        python
        rust
        toml
        tsx
        typescript
        yaml
        zig
      ]
    ))
  ];

  # Pure language servers + formatters that nvim alone uses.
  # Tools you also invoke from the terminal (ruff, ty, ...) live in Homebrew
  # and are picked up via PATH; do not duplicate them here.
  extraPackages = with pkgs; [
    bash-language-server
    clang-tools
    dockerfile-language-server
    gopls
    lua-language-server
    marksman
    nixd
    nixfmt
    rust-analyzer
    shfmt
    stylua
    terraform-ls
    typescript
    typescript-language-server
    vscode-langservers-extracted
    yaml-language-server
    zls
  ];
}
