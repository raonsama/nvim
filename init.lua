-- ============================================================
-- init.lua — Entry Point Neovim
-- Struktur: LazyVim-inspired | Target: Termux Android
-- ============================================================

-- Nonaktifkan provider yang tidak dipakai di Termux (hemat startup time)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0

-- Nonaktifkan netrw (pakai nvim-tree sebagai pengganti)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Leader key harus di-set SEBELUM lazy dimuat
vim.g.mapleader      = ' '
vim.g.maplocalleader = '\\'

-- ── Load konfigurasi dasar ────────────────────────────────────
require('config.options')   -- Opsi editor
require('config.autocmds')  -- Auto commands
require('config.keymaps')   -- Keymap global

-- ── Bootstrap lazy.nvim ──────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.notify('Mengunduh lazy.nvim...', vim.log.levels.INFO)
  vim.fn.system({
    'git', 'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Setup lazy.nvim ──────────────────────────────────────────
require('lazy').setup({
  spec = {
    { import = 'plugins.core' }, -- Plugin inti (UI, treesitter, dll)
    { import = 'plugins.lsp' },  -- LSP, completion, formatter
  },

  -- Default: lazy-load semua plugin (penting untuk Termux)
  defaults = { lazy = true },

  -- Disable Rocks
  rocks = { enabled   = false, hererocks = false },

  -- Gunakan colorscheme fallback saat install pertama
  install = { colorscheme = { 'tokyonight', 'habamax' } },

  -- Matikan auto-check update (hemat baterai/data di Termux)
  checker = { enabled = false },

  -- Performa: disable plugin bawaan yang tidak dipakai
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip',
        'matchit',
        'matchparen',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        '2html_plugin',
        'getscript',
        'getscriptPlugin',
        'logipat',
        'rrhelper',
        'spellfile_plugin',
        'vimball',
        'vimballPlugin',
      },
    },
  },

  ui = {
    border = 'rounded',
    backdrop = 60,
  },

  change_detection = { enabled = false }, -- Jangan watch perubahan file
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    -- Cek apakah argumen yang diberikan adalah direktori
    local is_directory = vim.fn.isdirectory(data.file) == 1
    if not is_directory then return end

    -- Pindah ke direktori tersebut sebagai cwd
    vim.cmd.cd(data.file)

    -- Schedule agar buffer sempat siap sebelum dimanipulasi
    vim.schedule(function()
      -- Hapus buffer direktori (bukan file, tidak perlu ditampilkan)
      if vim.api.nvim_buf_is_valid(data.buf) then
        vim.cmd("bwipeout! " .. data.buf)
      end
      -- Buat buffer kosong sebagai kanvas utama
      vim.cmd("enew")
      -- Buka nvim-tree di sisi kiri
      local ok, nt_api = pcall(require, "nvim-tree.api")
      if ok then nt_api.tree.open() end
    end)
  end,
})
