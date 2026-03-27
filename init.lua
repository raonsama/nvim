-- ============================================================
-- NEOVIM CONFIG — init.lua (root)
-- Target : Termux Android, Neovim 0.11+
-- Prinsip: Cepat, ringan, tidak ada yang jalan kalau tidak perlu
-- ============================================================

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] PROVIDER                    ║
-- ║  Matikan provider bahasa yang tidak dipakai.             ║
-- ║  Setiap provider aktif = +40-80ms lag saat startup       ║
-- ║  karena Neovim men-probe ketersediaannya satu per satu.  ║
-- ╚══════════════════════════════════════════════════════════╝
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_perl_provider    = 0

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] NETRW                       ║
-- ║  Harus dimatikan SEBELUM plugin manager di-load.         ║
-- ║  Kita pakai nvim-tree sebagai pengganti netrw.           ║
-- ╚══════════════════════════════════════════════════════════╝
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] LEADER KEY                  ║
-- ║  Harus di-set SEBELUM lazy.nvim di-load agar semua       ║
-- ║  keymap plugin menggunakan leader yang benar.            ║
-- ╚══════════════════════════════════════════════════════════╝
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] CORE CONFIG                 ║
-- ║  Load options dan keymaps sebelum plugin agar            ║
-- ║  pengaturan dasar sudah aktif sejak awal.                ║
-- ╚══════════════════════════════════════════════════════════╝
require("core.options")
require("core.keymaps")

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] LAZY.NVIM                   ║
-- ║  Plugin manager. Auto-download jika belum ada.           ║
-- ║  Menggunakan --filter=blob:none agar clone lebih cepat   ║
-- ║  (tidak download history git yang tidak diperlukan).     ║
-- ╚══════════════════════════════════════════════════════════╝
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ╔══════════════════════════════════════════════════════════╗
-- ║                  [MANDATORY] SETUP LAZY                  ║
-- ╚══════════════════════════════════════════════════════════╝
require("lazy").setup("plugins", {
  performance = {
    rtp = {
      -- Matikan built-in plugin bawaan Neovim yang tidak dipakai.
      -- Ini mengurangi waktu startup karena Neovim tidak perlu
      -- men-source file-file ini saat booting.
      disabled_plugins = {
        "gzip",        -- buka file .gz      → tidak dipakai
        "tarPlugin",   -- buka file .tar     → tidak dipakai
        "zipPlugin",   -- buka file .zip     → tidak dipakai
        "tohtml",      -- konversi ke HTML   → tidak dipakai
        "tutor",       -- :Tutor interaktif  → tidak dipakai
        "matchit",     -- match bracket      → diganti treesitter
        "netrwPlugin", -- file explorer      → diganti nvim-tree
      },
    },
  },

  -- [OPTIONAL] Rocks: disable karena tidak dipakai dan
  -- memerlukan hererocks (C compiler) yang berat di Termux.
  rocks = {
    enabled   = false,
    hererocks = false,
  },

  -- [OPTIONAL] Matikan auto-check update plugin.
  -- Di Termux, network call latar belakang bisa mengganggu performa.
  -- Update manual via <leader>l → Lazy → U
  checker = { enabled = false },

  -- [OPTIONAL] Matikan notifikasi saat config file berubah.
  -- Hemat CPU karena tidak ada file-watcher tambahan.
  change_detection = { notify = false },
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║             [OPTIONAL] AUTO BUKA NVIM-TREE               ║
-- ║  Jika Neovim dibuka dengan argumen direktori             ║
-- ║  (contoh: nvim .), otomatis buka nvim-tree.              ║
-- ╚══════════════════════════════════════════════════════════╝
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
