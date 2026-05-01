-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Helper: set keymap dengan opsi default
local function map(mode, lhs, rhs, desc, extra)
  local o = vim.tbl_extend('force', { noremap = true, silent = true, desc = desc }, extra or {})
  vim.keymap.set(mode, lhs, rhs, o)
end

-- ── Pilih Semua (Select All) ──────────────────────────────────
map('n', '<C-a>', 'ggVG',      'Pilih semua')
map('i', '<C-a>', '<Esc>ggVG', 'Pilih semua')

-- ── Copy / Cut / Paste ────────────────────────────────────────
map('n', '<C-c>', 'vy',  'Salin')
map('v', '<C-c>', 'y',   'Salin (visual)')
map('v', '<C-x>', 'd',   'Potong (visual)')
map('n', '<C-x>', 'dd',  'Potong baris')

-- ── Duplikasi Baris ───────────────────────────────────────────
map('n', '<C-d>', 'yyp',  'Duplikasi baris')
map('v', '<C-d>', "y'>p", 'Duplikasi seleksi')

-- ── Pindah Baris (Alt+Shift+Up/Down = Sublime style) ──────────
map('n', '<A-Up>',   ':m .-2<cr>==',     'Pindah baris ke atas')
map('n', '<A-Down>', ':m .+1<cr>==',     'Pindah baris ke bawah')
map('v', '<A-Up>',   ":m '<-2<cr>gv=gv", 'Pindah seleksi ke atas')
map('v', '<A-Down>', ":m '>+1<cr>gv=gv", 'Pindah seleksi ke bawah')

-- ── Go to Line ───────────────────────────────────────────────
map('n', '<C-g>', function()
  local line = vim.fn.input('Pergi ke baris: ')
  if line ~= '' and tonumber(line) then
    vim.cmd(line)
  end
end, 'Pergi ke baris')

-- ── Clear Search Highlight ───────────────────────────────────
map('n', '<Esc>', '<cmd>nohlsearch<cr>', 'Hapus highlight pencarian')

-- Ctrl+Tab / Ctrl+Shift+Tab = Navigasi buffer (Sublime: tab)
map('n', '<A-]>',   '<cmd>bnext<cr>', 'Buffer berikutnya')
map('n', '<A-[>', '<cmd>bprev<cr>', 'Buffer sebelumnya')
map('n', '<C-n>',     ':enew<CR>',      'Buffer baru')

-- ============================================================
-- MISC YANG BERGUNA
-- ============================================================

-- Pertahankan seleksi visual setelah paste
map('v', 'p', '"_dP', 'Paste tanpa yank ulang')

-- Jangan yank saat delete karakter tunggal
map({ 'n', 'v' }, 'x', '"_x', 'Hapus karakter (tanpa yank)')

-- Delete (d, D) -> Black hole register
map({'n', 'v'}, 'd', '"_d')
map({'n', 'v'}, 'D', '"_D')

-- Change (c, C) -> Black hole register
map({'n', 'v'}, 'c', '"_c')
map({'n', 'v'}, 'C', '"_C')

-- Delete single char (x) -> Black hole register
map({'n', 'v'}, 'x', '"_x')
