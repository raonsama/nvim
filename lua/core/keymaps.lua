local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- --- 1. SMART SAVE DIALOG (Ctrl+S) ---
local function smart_save()
    if vim.fn.expand('%') == "" then
        local filename = vim.fn.input("Save as: ")
        if filename ~= "" then vim.cmd("write " .. filename) end
    else
        vim.cmd("write")
    end
end
keymap('n', '<C-s>', smart_save, opts)
-- FIX: Gunakan vim.schedule agar mode benar-benar berganti ke Normal
-- sebelum smart_save dieksekusi. Tanpa ini ada race condition kecil.
keymap('i', '<C-s>', function()
    vim.cmd("stopinsert")
    vim.schedule(smart_save)
end, opts)

-- --- 2. SMART CLOSE & QUIT ---
local function close_buffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

    local function do_close()
        local next_buf = nil
        -- Cari buffer file lain yang sedang terbuka
        for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
            if buf.bufnr ~= bufnr then
                local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf.bufnr })
                -- Prioritaskan pindah ke file normal (bukan terminal)
                if buftype == "" then
                    next_buf = buf.bufnr
                    break
                end
                -- Fallback jika tidak ada opsi lain
                if next_buf == nil then next_buf = buf.bufnr end
            end
        end

        if next_buf then
            -- 1. Pindah ke buffer selanjutnya TERLEBIH DAHULU agar window layout tidak rusak
            vim.cmd("buffer " .. next_buf)
        else
            -- 2. Jika ini adalah file terakhir, buat buffer kosong di window ini
            vim.cmd("enew")
        end

        -- 3. Baru hapus buffer aslinya di background
        pcall(function()
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end)
    end

    if is_modified then
        local choice = vim.fn.confirm("Simpan perubahan?", "&Yes\n&No\n&Cancel", 1)
        if choice == 1 then
            smart_save()
            do_close()
        elseif choice == 2 then
            do_close()
        end
    else
        do_close()
    end
end

keymap('n', '<C-w>', close_buffer, { noremap = true, silent = true, nowait = true })
keymap('n', '<C-q>', ':qa<CR>', opts)

-- --- 3. NAVIGASI & EDITING (Sublime Style) ---
keymap('n', '<C-n>', ':enew<CR>', opts)
keymap('n', '<C-p>', ':Telescope find_files<CR>', opts)
keymap('n', '<C-f>', ':Telescope live_grep<CR>', opts)
keymap('n', '<C-b>', ':NvimTreeToggle<CR>', opts)
keymap('n', '<C-a>', 'ggVG', opts)
keymap('n', '<C-d>', 'yyp', opts)
keymap('v', '<C-d>', 'yPgv', opts)

-- Move Lines (Alt + Arrows)
keymap('n', '<A-Down>', ':m .+1<CR>==', opts)
keymap('n', '<A-Up>', ':m .-2<CR>==', opts)
keymap('v', '<A-Down>', ":m '>+1<CR>gv=gv", opts)
keymap('v', '<A-Up>', ":m '<-2<CR>gv=gv", opts)

-- Comment (Ctrl+/)
keymap('n', '<C-_>', 'gcc', { remap = true })
keymap('v', '<C-_>', 'gc', { remap = true })

-- --- 4. TOGGLE NOTIFICATION ---
-- FIX: Simpan referensi notify ASLI terlebih dahulu.
-- Sebelumnya restore ke `print` yang tidak kompatibel dengan signature vim.notify
-- dan akan override handler plugin notifikasi (seperti nvim-notify, noice.nvim).
local _original_notify = vim.notify
local notifications_enabled = true

keymap('n', '<leader>n', function()
    notifications_enabled = not notifications_enabled
    if notifications_enabled then
        vim.notify = _original_notify  -- restore ke handler asli, bukan ke `print`
        vim.api.nvim_echo({{"󰂚 Notifikasi: ON", "Character"}}, false, {})
    else
        vim.notify = function() end
        vim.api.nvim_echo({{"󰂛 Notifikasi: OFF", "WarningMsg"}}, false, {})
    end
end, opts)

-- --- 5. LSP & TOOLS ---
keymap('n', 'gd', vim.lsp.buf.definition, opts)
keymap('n', 'K', vim.lsp.buf.hover, opts)
keymap('n', '<leader>h', function() require('spectre').toggle() end, opts)

-- --- 6. INTEGRATED TERMINAL ---
local M = {}
M.term_buf = nil
M.term_win = nil

local function toggle_terminal()
  -- Validasi window DAN buffer sekaligus
  if M.term_win and vim.api.nvim_win_is_valid(M.term_win) then
    -- Pastikan tidak close window saat sudah di window lain
    local cur_win = vim.api.nvim_get_current_win()
    if cur_win ~= M.term_win then
      -- Kalau fokus bukan di terminal, fokus ke terminal dulu
      vim.api.nvim_set_current_win(M.term_win)
    else
      -- Kalau sudah di terminal, baru close
      vim.api.nvim_win_close(M.term_win, true)
      M.term_win = nil
    end
    return
  end

  vim.cmd("botright split")
  vim.cmd("resize 10")

  if M.term_buf and vim.api.nvim_buf_is_valid(M.term_buf) then
    vim.api.nvim_set_current_buf(M.term_buf)
  else
    vim.cmd("term")
    M.term_buf = vim.api.nvim_get_current_buf()
    vim.wo.number         = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn     = "no"
  end

  M.term_win = vim.api.nvim_get_current_win()
end

keymap('n', '<A-t>', toggle_terminal, { noremap = true, silent = true })
keymap('t', '<A-t>', function()
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true),
    'n', false
  )
  vim.schedule(toggle_terminal)
end, { noremap = true, silent = true })

-- --- 7 PLUGIN MANAGER & INSTALLER ---
-- Spasi + l untuk buka menu Lazy (Update/Install plugin)
keymap('n', '<leader>l', '<cmd>Lazy<CR>', opts)
-- Spasi + m untuk buka menu Mason (Install LSP/Linter/Formatter)
keymap('n', '<leader>m', '<cmd>Mason<CR>', opts)
