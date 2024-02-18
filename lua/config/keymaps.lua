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

-- Disable keymaps
vim.keymap.set("n", "?", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-u>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<C-d>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<A-j>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", "<Nop>", { noremap = true, silent = true })

vim.keymap.set("n", "<S-h>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-l>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "[b", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "]b", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab>l", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab>f", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab><tab>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab>]", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab>[", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><tab>d", "<Nop>", { noremap = true, silent = true })

-- Remaping

-- Duplicate line
vim.keymap.set("n", "<C-d>", "yyp", { noremap = true, silent = true, desc = "Duplicate Line" })
vim.keymap.set("i", "<C-d>", "<esc>yypi", { noremap = true, silent = true, desc = "Duplicate Line" })

-- Move line
vim.keymap.set("n", "<C-S-Down>", "<cmd>m .+1<cr>==", { noremap = true, silent = true, desc = "Move down" })
vim.keymap.set("n", "<C-S-Up>", "<cmd>m .-2<cr>==", { noremap = true, silent = true, desc = "Move up" })
vim.keymap.set("i", "<C-S-Down>", "<esc><cmd>m .+1<cr>==gi", { noremap = true, silent = true, desc = "Move down" })
vim.keymap.set("i", "<C-S-Up>", "<esc><cmd>m .-2<cr>==gi", { noremap = true, silent = true, desc = "Move up" })
vim.keymap.set("v", "<C-S-Down>", ":m '>+1<cr>gv=gv", { noremap = true, silent = true, desc = "Move down" })
vim.keymap.set("v", "<C-S-Up>", ":m '<-2<cr>gv=gv", { noremap = true, silent = true, desc = "Move up" })

-- Switch buffer
vim.keymap.set("n", "<M-tab>", "<cmd>bnext<cr>", { noremap = true, silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<S-tab>", "<cmd>bprevious<cr>", { noremap = true, silent = true, desc = "Prev buffer" })

-- Select text using Shift+arrow keys in normal mode
vim.keymap.set("n", "<S-Right>", "vll", { noremap = true, silent = true, desc = "Select one character to right" })
vim.keymap.set("i", "<S-Right>", "<esc>vll", { noremap = true, silent = true, desc = "Select one character to right" })
vim.keymap.set("n", "<S-Left>", "vhh", { noremap = true, silent = true, desc = "Select one character to left" })
vim.keymap.set("i", "<S-Left>", "<esc>vhh", { noremap = true, silent = true, desc = "Select one character to left" })
vim.keymap.set("n", "<S-Up>", "vk", { noremap = true, silent = true, desc = "Select one line up" })
vim.keymap.set("i", "<S-Up>", "<esc>vk", { noremap = true, silent = true, desc = "Select one line up" })
vim.keymap.set("n", "<S-Down>", "vj", { noremap = true, silent = true, desc = "Select one line down" })
vim.keymap.set("i", "<S-Down>", "<esc>vj", { noremap = true, silent = true, desc = "Select one line down" })
