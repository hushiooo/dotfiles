{
  config,
  pkgs,
  dotfiles,
  ...
}:
{
  # Live symlink: Lua edits apply on the next nvim start, no rebuild needed.
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/config/nvim";

  programs.neovim = {
    enable = true;
    # init.lua is ours (config/nvim); load HM's generated Lua via the wrapper.
    sideloadInitLua = true;
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
      vim-tmux-navigator
      yanky-nvim
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

    # Language servers and formatters that only nvim invokes. Tools you also run
    # from the shell (ruff, ty, sqlfluff, ...) live in home.nix packages and are
    # found on PATH; do not duplicate them here.
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
  };
}
