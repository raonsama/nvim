-- ============================================================
-- config/keymaps.lua — Keymap Global
-- Gaya Sublime Text + navigasi Neovim
-- Catatan: Keymap spesifik plugin ada di plugins/core.lua (which-key)
--          Keymap LSP ada di plugins/lsp.lua (LspAttach)
-- ============================================================

-- Helper: set keymap dengan opsi default
local function map(mode, lhs, rhs, desc, extra)
  local o = vim.tbl_extend('force', { noremap = true, silent = true, desc = desc }, extra or {})
  vim.keymap.set(mode, lhs, rhs, o)
end

-- ============================================================
-- SUBLIME TEXT STYLE KEYMAPS
-- ============================================================

-- ── Simpan File / Quit All ────────────────────────────────────
-- Ctrl+S = Simpan (bekerja di normal, insert, visual mode)
map({ 'n', 'i', 'v' }, '<C-s>', function() 
  vim.cmd("stopinsert")
  vim.schedule(require('config.utils').save_as)
end, 'Simpan file')
map('n', '<A-q>', '<cmd>qa<cr>', 'Keluar semua')

-- ── Undo / Redo ───────────────────────────────────────────────
map('n', '<C-z>', 'u',           'Undo')
map('i', '<C-z>', '<Esc>u',      'Undo')
map('n', '<C-y>', '<C-r>',       'Redo')
map('i', '<C-y>', '<Esc><C-r>i', 'Redo')

-- ── Pilih Semua (Select All) ──────────────────────────────────
map('n', '<C-a>', 'ggVG',      'Pilih semua')
map('i', '<C-a>', '<Esc>ggVG', 'Pilih semua')

-- ── Copy / Cut / Paste ────────────────────────────────────────
map('n', '<C-c>', 'vy',  'Salin')
map('v', '<C-c>', 'y',   'Salin (visual)')
map('v', '<C-x>', 'd',   'Potong (visual)')
map('n', '<C-x>', 'dd',  'Potong baris')

-- ── Toggle Komentar (built-in Neovim 0.10+ gc/gcc) ────────────
-- <C-_> adalah Ctrl+/ di terminal
map('n', '<C-_>', 'gcc', 'Toggle komentar baris', { remap = true })
map('v', '<C-_>', 'gc',  'Toggle komentar blok',  { remap = true })

-- ── Duplikasi Baris ───────────────────────────────────────────
map('n', '<C-d>', 'yyp',  'Duplikasi baris')
map('v', '<C-d>', "y'>p", 'Duplikasi seleksi')

-- ── Pilih Baris ───────────────────────────────────────────────
-- Catatan: <C-l> konflik dengan window nav, gunakan leader-alt
map('n', '<leader><leader>l', 'V', 'Pilih baris')

-- ── Pindah Baris (Alt+Shift+Up/Down = Sublime style) ──────────
map('n', '<A-Up>',   ':m .-2<cr>==',     'Pindah baris ke atas')
map('n', '<A-Down>', ':m .+1<cr>==',     'Pindah baris ke bawah')
map('v', '<A-Up>',   ":m '<-2<cr>gv=gv", 'Pindah seleksi ke atas')
map('v', '<A-Down>', ":m '>+1<cr>gv=gv", 'Pindah seleksi ke bawah')

-- ── Indentasi ─────────────────────────────────────────────────
-- Tab / Shift+Tab di visual mode = indent/unindent (Sublime style)
map('v', '<Tab>',   '>gv', 'Indent lebih')
map('v', '<S-Tab>', '<gv', 'Indent kurang')

-- ── Go to Line ───────────────────────────────────────────────
map('n', '<C-g>', function()
  local line = vim.fn.input('Pergi ke baris: ')
  if line ~= '' and tonumber(line) then
    vim.cmd(line)
  end
end, 'Pergi ke baris')

-- ── Smart Home (Toggle awal baris / non-whitespace) ───────────
map({ 'n', 'v' }, '<Home>', function()
  local col = vim.fn.col('.')
  -- Posisi karakter pertama non-whitespace
  local first_char = vim.fn.match(vim.fn.getline('.'), '\\S') + 1
  if col == first_char then
    vim.cmd('normal! 0') -- Sudah di non-ws, pergi ke kolom 0
  else
    vim.cmd('normal! ^') -- Pergi ke non-whitespace pertama
  end
end, 'Smart Home')
map('i', '<Home>', '<Esc>^i', 'Smart Home (insert)')

-- ============================================================
-- NAVIGASI & WINDOW
-- ============================================================

-- ── Clear Search Highlight ───────────────────────────────────
map('n', '<Esc>', '<cmd>nohlsearch<cr>', 'Hapus highlight pencarian')

-- ── Better j/k untuk wrapped lines ───────────────────────────
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ── Navigasi Window (Ctrl+hjkl) ───────────────────────────────
map('n', '<C-h>', '<C-w>h', 'Window kiri')
map('n', '<C-j>', '<C-w>j', 'Window bawah')
map('n', '<C-k>', '<C-w>k', 'Window atas')
map('n', '<C-l>', '<C-w>l', 'Window kanan')

-- ── Resize Window ─────────────────────────────────────────────
map('n', '<C-Up>',    '<cmd>resize +2<cr>',          'Perbesar tinggi')
map('n', '<C-Down>',  '<cmd>resize -2<cr>',          'Perkecil tinggi')
map('n', '<C-Left>',  '<cmd>vertical resize -2<cr>', 'Perkecil lebar')
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', 'Perbesar lebar')

-- ============================================================
-- BUFFER / TAB
-- ============================================================

-- Ctrl+W = Tutup buffer dengan konfirmasi
map('n', '<C-w>', function()
  vim.schedule(require('config.utils').close_buffer)
end, 'Tutup buffer')

-- Ctrl+Tab / Ctrl+Shift+Tab = Navigasi buffer (Sublime: tab)
map('n', '<A-]>',   '<cmd>bnext<cr>', 'Buffer berikutnya')
map('n', '<A-[>', '<cmd>bprev<cr>', 'Buffer sebelumnya')
map('n', '<C-n>',     ':enew<CR>',      'Buffer baru')

-- ============================================================
-- TERMINAL
-- ============================================================

-- Ctrl+` = Toggle floating terminal (built-in)
map({ 'n', 'i', 'v', 't' }, "<A-t>", function()
  vim.schedule(require('config.utils').toggle_float_term)
end, 'Toggle terminal floating')
map({ 'n', 'i', 'v', 't' }, "<A-S-t>", function()
  require('config.utils').toggle_term('horizontal')
end, 'Toggle terminal horizontal')
map({ 'n', 'i', 'v', 't' }, "<C-A-t>", function()
  require('config.utils').toggle_term('vertical')
end, 'Toggle terminal vertical')

-- Keluar dari mode terminal dengan Esc atau Ctrl+Q
map('t', '<Esc><Esc>', '<C-\\><C-n>', 'Keluar mode terminal')
map('t', '<C-q>',      '<C-\\><C-n>', 'Keluar mode terminal')

-- Navigasi window dari dalam terminal
map('t', '<C-h>', '<C-\\><C-n><C-w>h', 'Window kiri (terminal)')
map('t', '<C-j>', '<C-\\><C-n><C-w>j', 'Window bawah (terminal)')
map('t', '<C-k>', '<C-\\><C-n><C-w>k', 'Window atas (terminal)')
map('t', '<C-l>', '<C-\\><C-n><C-w>l', 'Window kanan (terminal)')

-- ============================================================
-- MISC YANG BERGUNA
-- ============================================================

-- Tambah baris baru tanpa masuk insert mode
map('n', '<leader>o',  'o<Esc>',  'Baris baru di bawah')
map('n', '<leader>O',  'O<Esc>',  'Baris baru di atas')

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

-- Pencarian lebih baik: pastikan hasil pencarian ada di tengah layar
map('n', 'n',  'nzzzv',  'Next hasil pencarian (center)')
map('n', 'N',  'Nzzzv',  'Prev hasil pencarian (center)')
map('n', '*',  '*zzzv',  'Cari kata di bawah kursor')
map('n', '#',  '#zzzv',  'Cari kata ke belakang')

-- Join lines tanpa pindah kursor
map('n', 'J', 'mzJ`z', 'Join baris (kursor tetap)')

-- Quick-fix navigation
map('n', '<leader>qn', '<cmd>cnext<cr>',     'QuickFix berikutnya')
map('n', '<leader>qp', '<cmd>cprev<cr>',     'QuickFix sebelumnya')
map('n', '<leader>qq', '<cmd>cclose<cr>',    'Tutup QuickFix')
map('n', '<leader>qo', '<cmd>copen<cr>',     'Buka QuickFix')
