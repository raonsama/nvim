-- ============================================================
-- config/autocmds.lua — Auto Commands
-- Proteksi file besar, highlight yank, terminal, dsb
-- ============================================================

local function augroup(name)
  return vim.api.nvim_create_augroup('sanex_' .. name, { clear = true })
end

-- ============================================================
-- 1. PROTEKSI FILE BESAR
-- File > 512KB: nonaktifkan treesitter, LSP, syntax, undo
-- ============================================================
local big_file_group = augroup('big_file')

vim.api.nvim_create_autocmd('BufReadPre', {
  group = big_file_group,
  desc  = 'Deteksi file besar dan nonaktifkan fitur berat',
  callback = function(ev)
    local utils = require('config.utils')
    if utils.is_big_file(ev.buf) then
      -- Tandai buffer sebagai file besar
      vim.b[ev.buf].big_file = true

      -- Nonaktifkan fitur yang boros memori/CPU
      vim.opt_local.swapfile   = false
      vim.opt_local.undofile   = false
      vim.opt_local.undolevels = -1
      vim.opt_local.foldmethod = 'manual'

      -- Nonaktifkan syntax highlighting
      vim.cmd('syntax off')

      -- Nonaktifkan treesitter (jika sudah aktif, stop-kan)
      pcall(vim.treesitter.stop)

      vim.notify(
        string.format('File besar (>512KB): Beberapa fitur dinonaktifkan untuk performa.'),
        vim.log.levels.WARN,
        { title = 'File Besar' }
      )
    end
  end,
})

-- Nonaktifkan treesitter di BufReadPost untuk file besar
vim.api.nvim_create_autocmd('BufReadPost', {
  group = big_file_group,
  desc  = 'Stop treesitter untuk file besar',
  callback = function(ev)
    if vim.b[ev.buf].big_file then
      pcall(vim.treesitter.stop)
      -- Matikan LSP di file besar
      local clients = vim.lsp.get_clients({ bufnr = ev.buf })
      for _, client in ipairs(clients) do
        vim.lsp.buf_detach_client(ev.buf, client.id)
      end
    end
  end,
})

-- ============================================================
-- 2. HIGHLIGHT YANK (bawaan Neovim)
-- ============================================================
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  desc  = 'Highlight teks yang baru di-yank',
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
})

-- ============================================================
-- 3. SETTING TERMINAL BUFFER
-- ============================================================
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup('terminal_setup'),
  desc  = 'Konfigurasi tampilan terminal buffer',
  callback = function()
    -- Nonaktifkan fitur yang tidak relevan di terminal
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn     = 'no'
    vim.opt_local.cursorline     = false
    vim.opt_local.spell          = false
    vim.opt_local.list           = false
    -- Langsung masuk insert mode saat terminal terbuka
    vim.cmd('startinsert')
  end,
})

-- Re-enter insert mode saat fokus kembali ke terminal window
vim.api.nvim_create_autocmd('BufEnter', {
  group   = augroup('terminal_insert'),
  desc    = 'Auto insert mode saat masuk terminal buffer',
  pattern = 'term://*',
  command = 'startinsert',
})

-- ============================================================
-- 4. AUTO RESIZE SPLIT WINDOW
-- ============================================================
vim.api.nvim_create_autocmd('VimResized', {
  group = augroup('resize_splits'),
  desc  = 'Equalise splits saat ukuran terminal berubah',
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- ============================================================
-- 5. RESTORE CURSOR POSITION
-- ============================================================
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('restore_cursor'),
  desc  = 'Kembalikan posisi kursor terakhir saat membuka file',
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local line_count = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ============================================================
-- 6. AUTO CREATE DIR SAAT SIMPAN
-- ============================================================
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   group = augroup('auto_create_dir'),
--   desc  = 'Buat direktori otomatis jika belum ada saat menyimpan',
--   callback = function(ev)
--     -- Jangan buat dir untuk file sementara/buffer khusus
--     if ev.match:match('^%w%w+:') then return end
--     local file = vim.uv.fs_realpath(ev.match) or ev.match
--     local dir  = vim.fn.fnamemodify(file, ':p:h')
--     if not vim.uv.fs_stat(dir) then
--       vim.fn.mkdir(dir, 'p')
--     end
--   end,
-- })

-- ============================================================
-- 7. FORMAT OPTIONS PER FILETYPE
-- ============================================================
-- Override formatoptions agar tidak auto-comment di baris baru
-- vim.api.nvim_create_autocmd('FileType', {
--   group = augroup('fix_format_options'),
--   desc  = 'Hapus auto-comment di baris baru',
--   callback = function()
--     vim.opt_local.formatoptions:remove({ 'r', 'o' })
--   end,
-- })

-- ============================================================
-- 8. TAMPILKAN DIAGNOSTIC DI FLOAT OTOMATIS
-- ============================================================
vim.api.nvim_create_autocmd('CursorHold', {
  group = augroup('show_diagnostic'),
  desc  = 'Tampilkan diagnostic saat kursor diam',
  callback = function()
    -- Hanya tampilkan jika tidak ada window floating yang sedang terbuka
    local has_float = false
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= '' then
        has_float = true
        break
      end
    end
    if not has_float then
      vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
    end
  end,
})
