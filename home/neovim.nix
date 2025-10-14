{ pkgs, ... }:
{
  enable = true;
  defaultEditor = true;
  viAlias = true;
  vimAlias = true;

  plugins = with pkgs.vimPlugins; [
    # UI and theming
    tokyonight-nvim
    lualine-nvim
    nvim-web-devicons
    nvim-notify
    dressing-nvim

    # Navigation and file management
    nvim-tree-lua
    telescope-nvim
    telescope-fzf-native-nvim
    which-key-nvim

    # Editing enhancements
    comment-nvim
    nvim-surround
    gitsigns-nvim

    # LSP and completion
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
    nvim-lint

    # Syntax highlighting
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        html
        typescript
        javascript
        css
        tsx
        python
        rust
        go
        c
        cpp
        lua
        json
        yaml
        toml
        nix
        bash
        dockerfile
        markdown
        markdown_inline
        git_rebase
        gitcommit
        gitignore
        regex
        vim
        hcl
      ]
    ))
  ];

  extraPackages = with pkgs; [
    # LSPs
    nodePackages.typescript-language-server
    lua-language-server
    gopls
    clang-tools
    rust-analyzer
    bash-language-server
    dockerfile-language-server
    yaml-language-server
    vscode-langservers-extracted
    marksman
    nixd
    terraform-ls
    pyright
    ruff
    ty
    stylua
    shfmt
    nixfmt-rfc-style
  ];
}
