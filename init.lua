-- ============================================================
-- NEOVIM CONFIG — init.lua (root)
-- Target: Termux Android, Neovim 0.11+
-- Prinsip: Cepat, ringan, tidak ada yang jalan kalau tidak perlu
-- ============================================================

-- --- MATIKAN PROVIDER YANG TIDAK DIPAKAI ---
-- Ini optimasi startup terbesar yang sering dilupakan.
-- Setiap provider yang aktif di-probe saat startup → +40-80ms lag.
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0

-- --- MATIKAN NETRW (harus sebelum plugin manager) ---
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- --- LEADER KEY ---
vim.g.mapleader = " "

-- --- LOAD KONFIGURASI DASAR ---
require("core.options")
require("core.keymaps")

-- --- BOOTSTRAP LAZY.NVIM ---
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- --- LOAD PLUGINS ---
require("lazy").setup("plugins", {
  performance = {
    rtp = {
      -- Matikan built-in plugin Neovim yang tidak dipakai untuk dev sehari-hari
      disabled_plugins = {
        "gzip",        -- buka file .gz
        "tarPlugin",   -- buka file .tar
        "zipPlugin",   -- buka file .zip
        "tohtml",      -- konversi buffer ke HTML
        "tutor",       -- :Tutor interaktif bawaan Neovim
        "matchit",     -- diganti treesitter
        "netrwPlugin", -- sudah dimatikan via g.loaded_*
      },
    },
  },
  -- Matikan auto-check update → tidak ada network call latar belakang di Termux
  checker = { enabled = false },
  -- Matikan notifikasi perubahan file config (hemat CPU saat coding)
  change_detection = { notify = false },
})

-- --- BUKA NVIMTREE JIKA ARGUMEN ADALAH DIREKTORI ---
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    local directory = vim.fn.isdirectory(data.file) == 1
    if directory then
      vim.cmd.cd(data.file)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(data.buf) then
          vim.cmd("bwipeout! " .. data.buf)
        end
        vim.cmd("enew")
        local ok, nt_api = pcall(require, "nvim-tree.api")
        if ok then nt_api.tree.open() end
      end)
    end
  end,
})
