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
    noice-nvim
    nvim-notify
    dressing-nvim

    # Navigation and file management
    nvim-tree-lua
    telescope-nvim
    telescope-fzf-native-nvim
    which-key-nvim
    plenary-nvim

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
    pyright
    lua-language-server
    gopls
    clang-tools
    rust-analyzer
    bash-language-server
    dockerfile-language-server-nodejs
    yaml-language-server
    vscode-langservers-extracted
    marksman
    nil
    tflint
    ruff
  ];

  extraConfig = "";
  extraLuaConfig = "";
}
