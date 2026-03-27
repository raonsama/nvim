-- ============================================================
-- NEOVIM CONFIG — core/keymaps.lua
-- Target : Termux Android, Neovim 0.11+
-- ============================================================
local keymap = vim.keymap.set
local opts   = { noremap = true, silent = true }

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] SMART SAVE (Ctrl+S)             ║
-- ║  Jika file belum punya nama → tanya nama file dulu.      ║
-- ║  Jika sudah punya nama → langsung simpan.                ║
-- ╚══════════════════════════════════════════════════════════╝
local function smart_save()
  if vim.fn.expand('%') == "" then
    local filename = vim.fn.input("Save as: ")
    if filename ~= "" then vim.cmd("write " .. filename) end
  else
    vim.cmd("write")
  end
end

keymap('n', '<C-s>', smart_save, opts)

-- Insert mode: stopinsert dulu sebelum save.
-- vim.schedule memastikan mode benar-benar berganti ke Normal
-- sebelum smart_save dieksekusi (cegah race condition).
keymap('i', '<C-s>', function()
  vim.cmd("stopinsert")
  vim.schedule(smart_save)
end, opts)

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] SMART CLOSE (Ctrl+W)            ║
-- ║  Tutup buffer dengan aman: pindah ke buffer lain dulu    ║
-- ║  agar layout window tidak rusak.                         ║
-- ╚══════════════════════════════════════════════════════════╝
local function close_buffer()
  local bufnr      = vim.api.nvim_get_current_buf()
  local is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

  local function do_close()
    local next_buf = nil

    -- Cari buffer file normal lain yang terbuka (bukan terminal)
    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if buf.bufnr ~= bufnr then
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf.bufnr })
        if buftype == "" then
          next_buf = buf.bufnr
          break
        end
        -- Fallback: ambil buffer apapun jika tidak ada file normal
        if next_buf == nil then next_buf = buf.bufnr end
      end
    end

    if next_buf then
      -- Pindah ke buffer lain DULU agar window tidak ikut tertutup
      vim.cmd("buffer " .. next_buf)
    else
      -- Tidak ada buffer lain → buat buffer kosong baru
      vim.cmd("enew")
    end

    -- Hapus buffer lama di background (force agar tidak tanya lagi)
    pcall(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end

  if is_modified then
    -- File belum disimpan → tanya ke user
    local choice = vim.fn.confirm("Simpan perubahan?", "&Yes\n&No\n&Cancel", 1)
    if choice == 1 then
      smart_save()
      do_close()
    elseif choice == 2 then
      do_close()
    end
    -- choice == 3 (Cancel) → tidak lakukan apa-apa
  else
    do_close()
  end
end

-- nowait=true: override default Neovim <C-w> (window commands) sepenuhnya
keymap('n', '<C-q>', close_buffer, { noremap = true, silent = true, nowait = true })

-- Keluar dari semua buffer sekaligus
keymap('n', '<A-q>', ':qa<CR>', opts)

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] NAVIGASI & EDITING              ║
-- ║  Gaya Sublime Text agar familiar bagi pengguna baru.     ║
-- ╚══════════════════════════════════════════════════════════╝

-- File & pencarian
keymap('n', '<C-n>', ':enew<CR>',                   opts)  -- file baru
keymap('n', '<C-p>', ':Telescope find_files<CR>',   opts)  -- cari file
keymap('n', '<C-f>', ':Telescope live_grep<CR>',    opts)  -- cari teks
keymap('n', '<C-b>', ':NvimTreeToggle<CR>',         opts)  -- file tree

-- Seleksi & duplikasi
keymap('n', '<C-a>', 'ggVG',   opts)   -- select all
keymap('n', '<C-d>', 'yyp',    opts)   -- duplikat baris (Normal)
keymap('v', '<C-d>', 'yPgv',   opts)   -- duplikat seleksi (Visual)

-- Pindah baris dengan Alt+Arrow
keymap('n', '<A-Down>', ':m .+1<CR>==',        opts)
keymap('n', '<A-Up>',   ':m .-2<CR>==',        opts)
keymap('v', '<A-Down>', ":m '>+1<CR>gv=gv",    opts)
keymap('v', '<A-Up>',   ":m '<-2<CR>gv=gv",    opts)

-- Pindah antar buffer (Alt + [ / ])
keymap('n', '<A-[>', ':bprevious<CR>', opts)
keymap('n', '<A-]>', ':bnext<CR>',     opts)

-- Comment: remap=true agar bisa memanggil mapping plugin (Comment.nvim)
keymap('n', '<C-_>', 'gcc', { remap = true })   -- Ctrl+/ Normal
keymap('v', '<C-_>', 'gc',  { remap = true })   -- Ctrl+/ Visual

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] TOGGLE NOTIFIKASI                ║
-- ║  <leader>n untuk mute/unmute semua vim.notify.           ║
-- ╚══════════════════════════════════════════════════════════╝

-- Simpan referensi handler ASLI sebelum di-override.
-- Penting: jangan restore ke `print` — signature-nya berbeda
-- dan akan konflik dengan plugin notifikasi (nvim-notify, noice).
local _original_notify    = vim.notify
local notifications_enabled = true

keymap('n', '<leader>n', function()
  notifications_enabled = not notifications_enabled
  if notifications_enabled then
    vim.notify = _original_notify
    vim.api.nvim_echo({{"󰂚 Notifikasi: ON", "Character"}}, false, {})
  else
    vim.notify = function() end   -- buang semua notifikasi
    vim.api.nvim_echo({{"󰂛 Notifikasi: OFF", "WarningMsg"}}, false, {})
  end
end, opts)

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] LSP                             ║
-- ╚══════════════════════════════════════════════════════════╝
keymap('n', 'gd',        vim.lsp.buf.definition,                     opts)  -- pergi ke definisi
keymap('n', 'K',         vim.lsp.buf.hover,                          opts)  -- dokumentasi hover
keymap('n', '<leader>h', function() require('spectre').toggle() end, opts)  -- find & replace

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] INTEGRATED TERMINAL              ║
-- ║  Alt+T: toggle terminal di bawah editor.                 ║
-- ║  - Buka  → split bawah 10 baris                          ║
-- ║  - Fokus → jika terminal sudah ada tapi tidak difokus    ║
-- ║  - Tutup → jika sudah di dalam terminal                  ║
-- ╚══════════════════════════════════════════════════════════╝

-- State terminal disimpan dalam table lokal (bukan _G global)
-- agar tidak mencemari namespace global Neovim.
local T = { buf = nil, win = nil }

local function toggle_terminal()
  if T.win and vim.api.nvim_win_is_valid(T.win) then
    local cur_win = vim.api.nvim_get_current_win()
    if cur_win ~= T.win then
      -- Terminal ada tapi tidak difokus → pindah fokus ke terminal
      vim.api.nvim_set_current_win(T.win)
    else
      -- Sudah di dalam terminal → tutup
      vim.api.nvim_win_close(T.win, true)
      T.win = nil
    end
    return
  end

  -- Buka split bawah dengan tinggi 10 baris
  vim.cmd("botright split")
  vim.cmd("resize 10")

  if T.buf and vim.api.nvim_buf_is_valid(T.buf) then
    -- Pakai kembali buffer terminal yang sudah ada (session tetap)
    vim.api.nvim_set_current_buf(T.buf)
  else
    -- Buat terminal baru
    vim.cmd("term")
    T.buf = vim.api.nvim_get_current_buf()
    -- Matikan dekorasi yang tidak perlu di terminal
    vim.wo.number         = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn     = "no"
  end

  T.win = vim.api.nvim_get_current_win()
end

-- Normal mode → buka/toggle terminal
-- nowait=true: cegah konflik dengan binding default Neovim
keymap('n', '<A-t>', toggle_terminal, { noremap = true, silent = true, nowait = true })

-- Terminal mode → keluar terminal mode dulu via feedkeys (lebih
-- reliable dari vim.cmd normal!), lalu toggle.
-- vim.schedule memastikan mode sudah berganti sebelum toggle dipanggil.
keymap('t', '<A-t>', function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
    'n', false
  )
  vim.schedule(toggle_terminal)
end, { noremap = true, silent = true, nowait = true })

-- BUG FIX: keymap Esc di terminal mode untuk keluar ke Normal.
-- Ini sering terhapus saat refactor — harus selalu ada.
keymap('t', '<Esc>', [[<C-\><C-n>]], opts)

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] PLUGIN MANAGER                   ║
-- ╚══════════════════════════════════════════════════════════╝
keymap('n', '<leader>l', '<cmd>Lazy<CR>',  opts)   -- buka Lazy (update plugin)
keymap('n', '<leader>m', '<cmd>Mason<CR>', opts)   -- buka Mason (install LSP)
