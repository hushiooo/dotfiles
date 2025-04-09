-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration
require('core.options')  -- Basic vim options
require('core.keymaps')  -- Key mappings
require('core.autocmds') -- Autocommands

-- Load plugins
require('plugins') -- Will load the plugins/init.lua file
