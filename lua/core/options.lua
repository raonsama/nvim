-- ============================================================
-- NEOVIM CONFIG — core/options.lua
-- Target : Termux Android, Neovim 0.11+
-- ============================================================
local opt = vim.opt

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] PERFORMA & RESPONSIVITAS        ║
-- ╚══════════════════════════════════════════════════════════╝

-- File swap & backup tidak diperlukan karena ada undofile.
-- Swap file juga lambat di Termux karena I/O Android terbatas.
opt.swapfile   = false
opt.backup     = false

-- Undo history tersimpan ke disk → bisa undo setelah Neovim ditutup.
opt.undofile   = true
opt.undolevels = 1000

-- shada: batasi history yang disimpan agar file .shada tidak membengkak.
-- '20  = simpan mark untuk 20 file terakhir
-- <50  = simpan max 50 baris per register
-- s10  = skip item > 10KB
-- h    = matikan hlsearch saat load
opt.shada = "'20,<50,s10,h"

-- updatetime: jeda sebelum CursorHold event & gitsigns update.
-- 1000ms cukup untuk Termux agar tidak terlalu sering trigger.
opt.updatetime = 1000

-- timeoutlen: waktu tunggu sequence keymap (misal <leader>x).
-- 300ms terasa responsif tanpa terlalu cepat.
opt.timeoutlen = 300

-- ttimeoutlen: waktu tunggu key code terminal (misal Esc).
-- 10ms agar Esc terasa instan.
opt.ttimeoutlen = 10

-- Batas kolom yang di-highlight per baris.
-- File minified (JS/CSS satu baris) bisa freeze jika tidak dibatasi.
-- Default 3000 → kita turunkan ke 200 (15x lebih ringan).
opt.synmaxcol = 200

-- redrawtime: timeout highlight syntax per frame sebelum dimatikan.
-- Turunkan dari default 2000ms untuk mencegah freeze di file kompleks.
opt.redrawtime = 1500

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] PERLINDUNGAN FILE BESAR         ║
-- ║  File > 500KB (vendor, minified) tidak perlu LSP/TS.     ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local max_size = 500 * 1024  -- 500KB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > max_size then
      vim.opt_local.syntax   = "off"  -- matikan syntax highlight
      vim.opt_local.filetype = ""     -- cegah filetype detection
      vim.opt_local.undofile = false  -- tidak perlu undo history
      vim.b.large_file       = true   -- flag untuk autocmd lain
      vim.notify("File besar terdeteksi — fitur berat dinonaktifkan", vim.log.levels.WARN)
    end
  end,
})

-- Jika LSP terlanjur attach ke large_file, langsung detach.
-- Tanpa ini LSP akan tetap jalan dan menghabiskan RAM/CPU.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.b[args.buf].large_file then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end)
    end
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] KONFIGURASI DIAGNOSTIK          ║
-- ╚══════════════════════════════════════════════════════════╝
vim.diagnostic.config({
  -- Jangan render diagnostic saat insert mode.
  -- Ini mencegah Neovim re-render underline merah setiap ketikan.
  update_in_insert = false,
  virtual_text     = true,    -- tampilkan pesan di akhir baris
  signs            = true,    -- tampilkan ikon di sign column
  underline        = true,    -- garis bawah pada kode bermasalah
  severity_sort    = true,    -- error di atas, hint di bawah
  float = {
    border = "rounded",
    source = true,            -- tampilkan nama LSP sumber error
  },
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] TAMPILAN UI                     ║
-- ╚══════════════════════════════════════════════════════════╝
opt.number         = true   -- tampilkan nomor baris
opt.relativenumber = true   -- nomor baris relatif (memudahkan navigasi)
opt.cursorline     = true   -- highlight baris kursor
opt.termguicolors  = true   -- aktifkan warna 24-bit (true color)
opt.splitright     = true   -- split vertikal → panel baru di kanan
opt.splitbelow     = true   -- split horizontal → panel baru di bawah
opt.showmode       = false  -- mode (INSERT/NORMAL) sudah di statusline
opt.laststatus     = 3      -- satu statusline global (bukan per window)
opt.signcolumn     = "yes"  -- kolom ikon selalu tampil (cegah layout geser)

-- penting untuk performa rendering.
-- Dengan wrap=true, baris panjang di-render karakter per karakter
-- di setiap baris layar → sangat lambat di ARM untuk file besar.
opt.wrap = false

-- Karakter pengisi area kosong di buffer.
-- eob=" " mengganti karakter "~" di bawah akhir file dengan spasi
-- sehingga tampilan lebih bersih.
opt.fillchars = {
  eob       = " ",  -- ganti ~ dengan spasi di bawah file
  vert      = "│",  -- garis pembatas split vertikal
  fold      = " ",  -- karakter pengisi fold
  -- foldopen  = "",  -- ikon fold terbuka
  -- foldclose = "",  -- ikon fold tertutup
}

-- Mouse: hanya aktif di Normal dan Visual mode.
-- "a" (semua mode) di Termux menyebabkan setiap touch/scroll
-- mengirim escape sequence yang harus di-parse Neovim → lag.
opt.mouse = "nv"

-- Clipboard: tidak sync otomatis ke OS clipboard.
-- Di Termux, "unnamedplus" memanggil termux-clipboard-get/set
-- (proses eksternal) setiap yank/paste → +50-200ms per operasi.
opt.clipboard = ""

-- Completion popup: maksimal 8 item yang ditampilkan.
-- Default unlimited → waste render cycle untuk item yang tidak terlihat.
opt.pumheight = 8

-- Scroll padding: pertahankan 8 baris di atas/bawah kursor.
-- Mencegah kursor menempel di tepi layar saat scroll.
opt.scrolloff     = 8
opt.sidescrolloff = 8

-- Folding dimatikan karena treesitter fold bisa berat di ARM.
-- Aktifkan manual jika diperlukan dengan :set foldenable
opt.foldenable = false

-- shortmess: kurangi pesan status yang tidak perlu.
-- c = jangan tampilkan "match 1 of 2" saat completion
-- I = jangan tampilkan intro screen saat Neovim baru dibuka
opt.shortmess:append("cI")

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] CMDLINE DINAMIS                 ║
-- ║  Sembunyi saat idle, muncul otomatis saat dibutuhkan.    ║
-- ╚══════════════════════════════════════════════════════════╝
opt.cmdheight = 0  -- sembunyikan cmdline saat tidak ada aktivitas

-- Tampilkan saat mengetik perintah (: / ? !)
vim.api.nvim_create_autocmd("CmdlineEnter", {
  callback = function() vim.opt.cmdheight = 1 end,
})

-- Sembunyikan kembali setelah perintah selesai.
-- defer_fn 100ms memberi waktu agar output sempat terbaca.
vim.api.nvim_create_autocmd("CmdlineLeave", {
  callback = function()
    vim.defer_fn(function()
      vim.opt.cmdheight = 0
    end, 100)
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] INDENTASI                       ║
-- ╚══════════════════════════════════════════════════════════╝
opt.tabstop     = 2      -- 1 tab = 2 spasi
opt.shiftwidth  = 2      -- lebar indent saat >> atau <<
opt.expandtab   = true   -- konversi tab ke spasi
opt.autoindent  = true   -- ikuti indent baris sebelumnya saat Enter
opt.smartindent = true   -- indent otomatis setelah { ( [
opt.breakindent = true   -- wrapped line mengikuti level indent

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [MANDATORY] PERFORMA INSERT MODE            ║
-- ║  Matikan fitur berat saat mengetik, nyalakan kembali     ║
-- ║  saat keluar. Ini yang paling berdampak di ARM.          ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    -- relativenumber: recalculate semua nomor baris setiap ketikan → lag
    -- cursorline: redraw highlight baris setiap ketikan → lag
    vim.opt.relativenumber = false
    vim.opt.cursorline     = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = true
    vim.opt.cursorline     = true
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] SYNC CLIPBOARD                   ║
-- ║  Sync ke OS clipboard hanya saat yank eksplisit,         ║
-- ║  bukan saat delete/change biasa.                         ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local event = vim.v.event
    -- operator "y" = yank eksplisit
    -- regname ""   = register default (bukan register bernama seperti "a)
    if event.operator == "y" and event.regname == "" then
      vim.fn.setreg("+", vim.fn.getreg('"'))
    end
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] AUTO NEW FILE                    ║
-- ║  Buat buffer kosong jika semua buffer ditutup.           ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    if #bufs == 0 then vim.cmd("enew") end
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] AUTOSAVE                         ║
-- ║  Simpan otomatis saat Neovim kehilangan fokus.           ║
-- ║  Hanya FocusLost → tidak ada disk I/O berlebihan.        ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local buftype = vim.bo.buftype
    local is_dir  = vim.fn.isdirectory(bufname) == 1
    -- Hanya simpan file normal (bukan terminal/direktori/buffer khusus)
    if bufname ~= "" and buftype == "" and not is_dir then
      vim.cmd("silent! write")
    end
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] TERMINAL AUTO INSERT             ║
-- ║  Otomatis masuk insert mode saat buka terminal buffer.   ║
-- ║  BufWinEnter dipilih (bukan BufEnter+WinEnter) agar      ║
-- ║  startinsert tidak dipanggil dua kali.                   ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern  = "term://*",
  callback = function() vim.cmd("startinsert") end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] FIX RESIZE GAP                   ║
-- ║  Saat ukuran terminal berubah (SIGWINCH), paksa          ║
-- ║  Neovim redraw penuh dan reset cmdheight.                ║
-- ╚══════════════════════════════════════════════════════════╝
vim.api.nvim_create_autocmd("VimResized", {
  callback = function()
    -- Samakan ukuran semua window split agar proporsional
    vim.cmd("wincmd =")
    -- defer_fn 50ms: beri waktu terminal selesai kirim dimensi baru
    -- sebelum Neovim redraw. Tanpa ini bisa ada gap sisa piksel.
    vim.defer_fn(function()
      vim.opt.cmdheight = 0
      vim.cmd("redraw!")
    end, 50)
  end,
})

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] GIT STATUS (CACHE)               ║
-- ║  Cache hasil gitsigns agar statusline tidak hitung       ║
-- ║  ulang setiap kali di-render (bisa ratusan kali/menit).  ║
-- ╚══════════════════════════════════════════════════════════╝
local _git_cache = ""

vim.api.nvim_create_autocmd("User", {
  pattern  = "GitSignsUpdate",
  callback = function()
    local gs = vim.b.gitsigns_status_dict
    if not gs or gs.head == "" then
      _git_cache = ""
      return
    end
    -- Format: " branch  +added  ~changed  -removed "
    _git_cache = string.format(" %s%s%s%s ",
      "  " .. gs.head,
      gs.added   and ("  " .. gs.added)   or "",
      gs.changed and ("  " .. gs.changed) or "",
      gs.removed and ("  " .. gs.removed) or ""
    )
  end,
})

local function git_status()
  return _git_cache
end

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] CUSTOM STATUSLINE                ║
-- ╚══════════════════════════════════════════════════════════╝
_G.my_statusline = function()
  return string.format("%s%s%s%s%s%s%s",
    "  ",       -- ikon mode (bisa dikembangkan)
    " %f",      -- nama file (path relatif)
    " %m",      -- flag modified [+]
    "%=",       -- pemisah kanan
    git_status(),
    " %y ",     -- filetype (contoh: [php])
    " %l:%c "   -- baris:kolom kursor
  )
end
opt.statusline = "%!v:lua.my_statusline()"

-- ╔══════════════════════════════════════════════════════════╗
-- ║              [OPTIONAL] CUSTOM FILETYPE                  ║
-- ╚══════════════════════════════════════════════════════════╝
-- Perlakukan file .blade sebagai HTML agar highlight bekerja.
vim.filetype.add({ extension = { blade = "html" } })
