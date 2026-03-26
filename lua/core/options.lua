-- ============================================================
-- NEOVIM CONFIG — core/options.lua
-- ============================================================
local opt = vim.opt

-- --- PERFORMANCE & UNDO ---
opt.swapfile   = false
opt.backup     = false
opt.undofile   = true
opt.undolevels = 1000
opt.shada      = "'20,<50,s10,h"
opt.updatetime = 1000

-- --- PERLINDUNGAN FILE BESAR ---
-- Baris panjang (minified JS/CSS) bisa freeze rendering karena Neovim
-- mencoba menghighlight setiap karakter. synmaxcol membatasi kolom
-- maksimal yang di-highlight per baris.
opt.synmaxcol = 200  -- default 3000, ini 15x lebih ringan

-- Proteksi LSP: matikan LSP untuk file > 500KB
-- File besar (vendor, minified) tidak perlu analisis LSP.
vim.api.nvim_create_autocmd("BufReadPre", {
  callback = function()
    local max_size = 500 * 1024  -- 500KB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > max_size then
      -- Matikan fitur berat untuk file ini
      vim.opt_local.syntax     = "off"
      vim.opt_local.filetype   = ""
      vim.opt_local.undofile   = false
      vim.b.large_file         = true
      vim.notify("File besar terdeteksi — fitur berat dinonaktifkan", vim.log.levels.WARN)
    end
  end,
})

-- Matikan treesitter & LSP di buffer yang large_file=true
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    if vim.b[args.buf].large_file then
      vim.schedule(function()
        vim.lsp.buf_detach_client(args.buf, args.data.client_id)
      end)
    end
  end,
})

-- Throttle diagnostic (kurangi frekuensi re-render underline merah saat mengetik)
vim.diagnostic.config({
  update_in_insert = false,   -- jangan render diagnostic saat insert mode
  virtual_text     = true,
  signs            = true,
  underline        = true,
  severity_sort    = true,
  float = {
    border = "rounded",
    source = true,
  },
})

-- --- UI: SUBLIME ELEGANCE ---
opt.number         = true
opt.relativenumber = true
opt.cursorline     = true
opt.termguicolors  = true
opt.splitright     = true
opt.splitbelow     = true
opt.mouse          = "a"
opt.clipboard      = "unnamedplus"
opt.laststatus     = 3
opt.showmode       = false
opt.cmdheight      = 0

opt.shortmess:append("cI")

-- --- INDENTASI ---
opt.tabstop    = 4
opt.shiftwidth = 4
opt.expandtab  = true

-- --- SMART AUTO-NEW FILE ---
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    if #bufs == 0 then vim.cmd("enew") end
  end,
})

-- --- AUTOSAVE ---
-- Hanya FocusLost — tidak ada disk I/O berlebihan saat ganti buffer
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    local bufname  = vim.api.nvim_buf_get_name(0)
    local buftype  = vim.bo.buftype
    local is_dir   = vim.fn.isdirectory(bufname) == 1
    if bufname ~= "" and buftype == "" and not is_dir then
      vim.cmd("silent! write")
    end
  end,
})

-- --- TERMINAL: STARTINSERT ---
-- BufWinEnter → terjadi sekali saat buffer ditampilkan di window
-- (BufEnter + WinEnter sering tumpuk → startinsert 2x)
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern  = "term://*",
  callback = function() vim.cmd("startinsert") end,
})

-- --- FUNGSI HELPER GIT STATUS ---
local function git_status()
  local gs = vim.b.gitsigns_status_dict
  if not gs or gs.head == "" then return "" end
  local branch  = "  " .. gs.head
  local added   = gs.added   and ("  " .. gs.added)   or ""
  local changed = gs.changed and ("  " .. gs.changed) or ""
  local removed = gs.removed and ("  " .. gs.removed) or ""
  return string.format("%s %s%s%s ", branch, added, changed, removed)
end

-- --- CUSTOM STATUSLINE ---
_G.my_statusline = function()
  return string.format("%s%s%s%s%s%s%s",
    "  ",           -- mode indicator
    " %f",          -- filename (relative)
    " %m",          -- modified flag
    "%=",           -- right-align separator
    git_status(),
    " %y ",         -- filetype
    " %l:%c "       -- baris:kolom
  )
end
opt.statusline = "%!v:lua.my_statusline()"

vim.filetype.add({ extension = { blade = "html" } })
