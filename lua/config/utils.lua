-- ============================================================
-- config/utils.lua — Fungsi utilitas
-- Terminal floating, lazygit, close buffer dengan konfirmasi
-- ============================================================

local M = {}

-- ── State terminal floating ───────────────────────────────────
-- Menyimpan buffer dan window ID agar bisa di-toggle
local float_term = { buf = -1, win = -1 }

-- ── Kalkulasi ukuran floating window ─────────────────────────
local function float_size(w_pct, h_pct)
  local width  = math.floor(vim.o.columns * w_pct)
  local height = math.floor(vim.o.lines * h_pct)
  local col    = math.floor((vim.o.columns - width) / 2)
  local row    = math.floor((vim.o.lines - height) / 2)
  return { width = width, height = height, col = col, row = row }
end

-- ── Buat config floating window ───────────────────────────────
local function make_float_config(size, title)
  return {
    relative = 'editor',
    width    = size.width,
    height   = size.height,
    col      = size.col,
    row      = size.row,
    style    = 'minimal',
    border   = 'rounded',
    title    = ' ' .. title .. ' ',
    title_pos = 'center',
  }
end

-- ── Toggle Terminal Floating (built-in Neovim terminal) ───────
-- Ctrl+` = Toggle on/off
-- Jika window sudah terbuka → tutup
-- Jika belum → buka dengan shell default
function M.toggle_float_term()
  -- Tutup jika window masih valid
  if vim.api.nvim_win_is_valid(float_term.win) then
    vim.api.nvim_win_close(float_term.win, false)
    float_term.win = -1
    return
  end

  local size = float_size(0.85, 0.80)

  -- Gunakan buffer yang sudah ada atau buat baru
  if not vim.api.nvim_buf_is_valid(float_term.buf) then
    float_term.buf = vim.api.nvim_create_buf(false, true)
  end

  -- Buka floating window
  float_term.win = vim.api.nvim_open_win(
    float_term.buf,
    true, -- Fokus ke window ini
    make_float_config(size, 'Terminal')
  )

  -- Set opsi window
  vim.wo[float_term.win].winblend    = 5
  vim.wo[float_term.win].winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder'

  -- Jalankan shell jika buffer belum berisi terminal
  if vim.bo[float_term.buf].buftype ~= 'terminal' then
    local shell = vim.o.shell
    vim.fn.termopen(shell, {
      on_exit = function()
        -- Bersihkan state saat shell keluar
        if vim.api.nvim_win_is_valid(float_term.win) then
          vim.api.nvim_win_close(float_term.win, true)
        end
        if vim.api.nvim_buf_is_valid(float_term.buf) then
          vim.api.nvim_buf_delete(float_term.buf, { force = true })
        end
        float_term.buf = -1
        float_term.win = -1
      end,
    })
  end

  -- Masuk ke mode terminal (insert)
  vim.cmd('startinsert')
end

-- ── Buka Terminal Horizontal (built-in) ──────────────────────
-- Split bawah dengan terminal
local term_buffers = {}

-- Helper untuk mendeteksi apakah window saat ini adalah sidebar/invalid
local function is_invalid_focus()
  local ft = vim.bo.filetype
  local bt = vim.bo.buftype
  
  -- Daftar filetype yang dilarang menjadi host terminal
  local forbidden_ft = { "neo-tree", "undotree", "diff" }
  
  for _, v in ipairs(forbidden_ft) do
    if ft == v then return true end
  end

  -- Terminal tidak boleh dibuka di atas buffer non-file (seperti prompt atau nofile)
  if bt ~= "" and bt ~= "terminal" then
    return true
  end

  return false
end

function M.toggle_term(direction)
  -- Guard Clause: Cegah eksekusi jika fokus di neo-tree
  if is_invalid_focus() then
    vim.notify("Aksi dibatalkan: Fokus berada pada sidebar atau buffer tidak valid.", vim.log.levels.WARN)
    return
  end

  local buf = term_buffers[direction]

  -- 1. Buffer Lifecycle Management
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    buf = vim.api.nvim_create_buf(false, true)
    term_buffers[direction] = buf
  end

  -- 2. Window Visibility Check
  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    vim.api.nvim_win_close(win, true)
    return
  end

  -- 3. Window Creation (Explicit over Clever)
  if direction == "horizontal" then
    vim.cmd("split")
    vim.cmd("resize 15")
  elseif direction == "vertical" then
    vim.cmd("vsplit")
  else
    error("Arah tidak valid: " .. tostring(direction))
  end

  -- Attach buffer to the new window
  vim.api.nvim_win_set_buf(0, buf)

  -- 4. Terminal Initialization (Idempotent)
  if vim.bo[buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell)
  end

  vim.cmd("startinsert")
end

-- ── Buka Lazygit di Floating Window ──────────────────────────
-- Memerlukan lazygit terinstall: pkg install lazygit (atau manual)
function M.open_lazygit()
  -- Cek apakah lazygit tersedia
  if vim.fn.executable('lazygit') == 0 then
    vim.notify('lazygit tidak ditemukan. Install dengan: pkg install lazygit', vim.log.levels.ERROR)
    return
  end

  local size = float_size(0.95, 0.92)
  local buf  = vim.api.nvim_create_buf(false, true)
  local win  = vim.api.nvim_open_win(buf, true, make_float_config(size, 'lazygit'))

  vim.wo[win].winblend = 0 -- Lazygit butuh tampilan bersih (no transparency)

  vim.fn.termopen('lazygit', {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
      -- Refresh gitsigns setelah lazygit ditutup
      pcall(function() require('gitsigns').refresh() end)
    end,
  })

  vim.cmd('startinsert')
end

-- ── Tutup Buffer dengan Konfirmasi ───────────────────────────
-- Jika ada perubahan belum disimpan, tampilkan dialog konfirmasi
function M.close_buffer()
  -- Guard Clause: Cegah eksekusi jika fokus di neo-tree
  if is_invalid_focus() then
    vim.notify("Aksi dibatalkan: Fokus berada pada sidebar atau buffer tidak valid.", vim.log.levels.WARN)
    return
  end

  local bufnr       = vim.api.nvim_get_current_buf()
  local is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

  local function do_close()
    local next_buf = nil
    for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
      if buf.bufnr ~= bufnr then
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf.bufnr })
        if buftype == "" then
          next_buf = buf.bufnr
          break
        end
        if next_buf == nil then next_buf = buf.bufnr end
      end
    end

    if next_buf then
      vim.cmd("buffer " .. next_buf)
    else
      vim.cmd("enew")
    end

    pcall(function()
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end)
  end

  if is_modified then
    local choice = vim.fn.confirm("Simpan perubahan?", "&Ya\n&Tidak\n&Batal", 1)
    if choice == 1 then
      local saved = M.save_as()
      if saved then do_close() end
    elseif choice == 2 then
      do_close()
    end
  else
    do_close()
  end
end

-- ── Save As (simpan dengan nama file baru) ───────────────────
function M.save_as()
  local current = vim.fn.expand('%')

  if current == "" then
    local new_name = vim.fn.input({
      prompt     = 'Simpan sebagai: ',
      default    = current,
      completion = 'file',
    })

    if new_name ~= "" then
     local ok, err = pcall(vim.cmd, 'saveas ' .. vim.fn.fnameescape(new_name))
      if ok then
        vim.notify('Disimpan sebagai: ' .. new_name, vim.log.levels.INFO)
      else
        vim.notify('Gagal: ' .. err, vim.log.levels.ERROR)
      end
      return true
    end
    return false
  else
    -- Guard Clause: Cegah eksekusi jika fokus di neo-tree
    if is_invalid_focus() then
      vim.notify("Aksi dibatalkan: Fokus berada pada sidebar atau buffer tidak valid.", vim.log.levels.WARN)
      return
    end

    vim.cmd('write')
    return true
  end
end

-- ── Proteksi File Besar (dipanggil dari autocmds) ─────────────
-- Nonaktifkan fitur berat untuk file > threshold
M.BIG_FILE_THRESHOLD = 1024 * 512 -- 512 KB

function M.is_big_file(bufnr)
  local filepath = vim.api.nvim_buf_get_name(bufnr or 0)
  if filepath == '' then return false end
  local size = vim.fn.getfsize(filepath)
  return size > M.BIG_FILE_THRESHOLD
end

return M
