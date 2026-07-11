-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.lazyvim_php_lsp = "intelephense"
vim.g.lazyvim_ts_lsp  = "vtsls"
vim.g.snacks_animate  = false
-- vim.g.autoformat = false

-- ============================================================
-- config/options.lua — Konfigurasi opsi Neovim
-- Dioptimalkan untuk performa Termux Android
-- ============================================================

local opt = vim.opt

-- ── Performa (KRITIS untuk Termux) ────────────────────────────
opt.updatetime     = 200   -- Frekuensi update CursorHold (ms), default 4000
opt.timeoutlen     = 300   -- Timeout menunggu keymap sequence (ms)
opt.redrawtime     = 1500  -- Batas waktu syntax highlight per frame
opt.maxmempattern  = 5000  -- Batas memori regex pattern (KB)
opt.synmaxcol      = 200   -- Batas kolom untuk syntax highlight (cegah lag baris panjang)

-- ── File & Penyimpanan ────────────────────────────────────────
opt.swapfile     = false  -- Tanpa swap file (hemat I/O di Termux)
opt.backup       = false  -- Tanpa backup file
opt.undofile     = true   -- Simpan undo history antar sesi
opt.undodir      = vim.fn.stdpath('data') .. '/undo'
opt.undolevels   = 1000
opt.shada        = "'20,<50,s10,h"
opt.clipboard    = 'unnamedplus' -- Fallback clipboard sistem

-- ── UI & Tampilan ─────────────────────────────────────────────
opt.termguicolors = true  -- Aktifkan warna 24-bit (true color)
opt.background    = 'dark'
opt.cmdheight     = 0     -- Sembunyikan cmdline; muncul hanya saat dibutuhkan
opt.showmode      = false -- Mode sudah ditampilkan di statusline (lualine)
opt.laststatus    = 3     -- Statusline global (satu untuk semua window)
opt.splitbelow    = true  -- Split horizontal ke bawah
opt.splitright    = true  -- Split vertikal ke kanan
opt.scrolloff     = 8     -- Jaga 8 baris di atas/bawah kursor
opt.sidescrolloff = 8     -- Jaga 8 kolom di kiri/kanan kursor
opt.wrap          = false -- Jangan wrap baris panjang
opt.pumheight     = 10    -- Maksimal 10 item di popup menu
opt.pumblend      = 0    -- Transparansi popup (0-100)

-- Buat direktori undo jika belum ada
vim.fn.mkdir(vim.fn.stdpath('data') .. '/undo', 'p')
