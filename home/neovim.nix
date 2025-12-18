{ pkgs }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # UI
    tokyonight-nvim
    lualine-nvim
    nvim-web-devicons
    dressing-nvim

    # Navigation
    nvim-tree-lua
    telescope-nvim
    telescope-fzf-native-nvim
    which-key-nvim

    # Editing
    gitsigns-nvim

    # LSP & Completion
    nvim-lspconfig
    nvim-cmp
    cmp-nvim-lsp
    cmp-buffer
    cmp-path
    cmp_luasnip
    luasnip

    # Debugging
    nvim-dap
    nvim-dap-python
    nvim-dap-ui
    nvim-dap-virtual-text
    telescope-dap-nvim

    # Search & Replace
    nvim-spectre

    # Utils
    plenary-nvim

    # Treesitter
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        python
        typescript
        javascript
        tsx
        go
        rust
        lua
        nix
        json
        yaml
        toml
        bash
        markdown
        hcl
      ]
    ))
  ];

  extraPackages = with pkgs; [
    nodePackages.typescript-language-server
    nodePackages.typescript
    nodePackages.vscode-langservers-extracted
    nodePackages.dockerfile-language-server-nodejs
    lua-language-server
    gopls
    rust-analyzer
    clang-tools
    marksman
    bash-language-server
    yaml-language-server
    nixd
    terraform-ls
    ruff
    stylua
    shfmt
    nixfmt-rfc-style
  ];
}
