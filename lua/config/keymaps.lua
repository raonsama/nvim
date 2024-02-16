-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

-- lazygit
vim.keymap.set("n", "<leader>gg",
  function()
    Util.terminal({ "lazygit" }, {
      cwd = Util.root(),
      esc_esc = false,
      ctrl_hjkl = false,
      size = {
        width = 1,
        height = 1,
      },
    })
  end, { desc = "Lazygit (root dir)" })

vim.keymap.set("n", "<leader>gG",
  function()
    Util.terminal({ "lazygit" }, {
      esc_esc = false,
      ctrl_hjkl = false,
      size = {
        width = 1,
        height = 1,
      },
    })
  end, { desc = "Lazygit (cwd)" })
