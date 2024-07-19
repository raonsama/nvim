-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.loaded_netrwPlugin = 0

local opt = vim.opt
opt.shiftwidth = 4 -- Size of an indent
opt.tabstop = 4 -- Number of spaces tabs count for
-- opt.softtabstop = 0 -- Number of columns for a TAB
opt.wrap = true -- Disable line wrap
opt.pumheight = 5 -- Maximum number of entries in a popup
opt.listchars = "tab:␉·" -- Invisible character
