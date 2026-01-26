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
    nvim-dap
    nvim-dap-python
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-lspconfig
    nvim-spectre
    nvim-web-devicons
    plenary-nvim
    telescope-dap-nvim
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
      ]
    ))
  ];

  extraPackages = with pkgs; [
    bash-language-server
    clang-tools
    gopls
    lua-language-server
    nixd
    nixfmt
    dockerfile-language-server
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted
    ruff
    ty
    rust-analyzer
    shfmt
    stylua
    terraform-ls
    yaml-language-server
  ];
}
