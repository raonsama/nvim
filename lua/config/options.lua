-- ============================================================
-- config/options.lua — Konfigurasi opsi Neovim
-- Dioptimalkan untuk performa Termux Android
-- ============================================================

-- Hide deprecation warnings
vim.g.deprecation_warnings = false

local opt = vim.opt

-- ── Tampilan Baris ────────────────────────────────────────────
opt.number         = true  -- Tampilkan nomor baris absolut
opt.relativenumber = true  -- Nomor baris relatif (navigasi cepat)
opt.cursorline     = true  -- Highlight baris aktif
opt.signcolumn     = 'yes' -- Selalu tampilkan sign column (git, lsp, dsb)
opt.colorcolumn    = ''  -- Garis panduan lebar 80 karakter

-- ── Indentasi ─────────────────────────────────────────────────
opt.tabstop     = 2    -- Tab = 2 spasi
opt.shiftwidth  = 2    -- Lebar indent = 2 spasi
opt.softtabstop = 2
opt.expandtab   = true -- Gunakan spasi bukan tab
opt.smartindent = true -- Auto-indent cerdas saat baris baru
opt.autoindent  = true

-- ── Pencarian ─────────────────────────────────────────────────
opt.hlsearch   = true  -- Highlight semua hasil pencarian
opt.incsearch  = true  -- Cari sambil mengetik (incremental)
opt.ignorecase = true  -- Case-insensitive secara default
opt.smartcase  = true  -- Case-sensitive jika ada huruf kapital

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


-- Karakter tak terlihat (whitespace visualization)
opt.list      = true
opt.listchars = { tab = '→ ', trail = '·', nbsp = '␣', extends = '›', precedes = '‹' }

-- Karakter border & pemisah window
opt.fillchars = {
  eob        = ' ',  -- Baris kosong di bawah buffer
  fold       = ' ',
  vert       = '│',  -- Pemisah window vertikal
  horiz      = '─',
  horizup    = '┴',
  horizdown  = '┬',
  vertleft   = '┤',
  vertright  = '├',
  verthoriz  = '┼',
}

-- ── Performa (KRITIS untuk Termux) ────────────────────────────
opt.updatetime     = 200   -- Frekuensi update CursorHold (ms), default 4000
opt.timeoutlen     = 300   -- Timeout menunggu keymap sequence (ms)
opt.redrawtime     = 1500  -- Batas waktu syntax highlight per frame
opt.maxmempattern  = 5000  -- Batas memori regex pattern (KB)
opt.synmaxcol      = 200   -- Batas kolom untuk syntax highlight (cegah lag baris panjang)
opt.lazyredraw     = false -- Jangan lazy redraw (bisa bug di beberapa versi)

-- ── File & Penyimpanan ────────────────────────────────────────
opt.swapfile     = false  -- Tanpa swap file (hemat I/O di Termux)
opt.backup       = false  -- Tanpa backup file
opt.undofile     = true   -- Simpan undo history antar sesi
opt.undodir      = vim.fn.stdpath('data') .. '/undo'
opt.undolevels   = 1000
opt.shada        = "'20,<50,s10,h"
opt.encoding     = 'utf-8'
opt.fileencoding = 'utf-8'
opt.autoread     = true   -- Reload file jika berubah di luar Neovim

-- ── Clipboard Termux ──────────────────────────────────────────
-- Gunakan termux-clipboard-get/set jika tersedia
if vim.fn.executable('termux-clipboard-get') == 1 then
  vim.g.clipboard = {
    name  = 'termux-clipboard',
    copy  = { ['+'] = 'termux-clipboard-set', ['*'] = 'termux-clipboard-set' },
    paste = { ['+'] = 'termux-clipboard-get', ['*'] = 'termux-clipboard-get' },
    cache_enabled = 0,
  }
else
  opt.clipboard = 'unnamedplus' -- Fallback clipboard sistem
end

-- ── Completion ────────────────────────────────────────────────
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.wildmode    = { 'longest:full', 'full' }
opt.wildignore  = { '*.o', '*.a', '*.class', '*.pyc', 'node_modules', '.git', 'vendor' }

-- ── Folding ───────────────────────────────────────────────────
opt.foldmethod    = 'indent' -- Fold berdasarkan indentasi (lebih cepat dari 'expr')
opt.foldlevel     = 99       -- Semua fold terbuka saat file dibuka
opt.foldlevelstart = 99

-- ── Misc ──────────────────────────────────────────────────────
opt.mouse          = 'a'    -- Aktifkan mouse penuh (berguna di Termux touchscreen)
opt.confirm        = false  -- Kita handle konfirmasi manual
opt.hidden         = true   -- Buffer tersembunyi tetap hidup di memori
opt.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }

-- Kurangi noise di command messages
opt.shortmess:append('I')  -- Sembunyikan intro/splash screen
opt.shortmess:append('c')  -- Sembunyikan pesan completion
opt.shortmess:append('C')  -- Sembunyikan pesan "scanning..." di completion
opt.shortmess:append('W')  -- Jangan tulis "[w]" saat file disimpan
opt.shortmess:append('F')  -- Jangan tulis nama file saat dibuka

-- Format options: jangan auto-insert comment di baris baru
opt.formatoptions:remove({ 'c', 'r', 'o' })

-- Buat direktori undo jika belum ada
vim.fn.mkdir(vim.fn.stdpath('data') .. '/undo', 'p')
