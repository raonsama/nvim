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
keymap('n', '<C-w>', function()
    local bufnr = vim.api.nvim_get_current_buf()
    local is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })

    if is_modified then
        local choice = vim.fn.confirm("Simpan perubahan?", "&Yes\n&No\n&Cancel", 1)
        if choice == 1 then smart_save(); vim.cmd("silent! bdelete")
        elseif choice == 2 then vim.cmd("silent! bdelete!") end
        return
    end

    if #bufs <= 1 then
        vim.cmd("enew")
        pcall(function()
            if vim.api.nvim_buf_is_valid(bufnr) then
                vim.api.nvim_buf_delete(bufnr, { force = true })
            end
        end)
    else
        vim.cmd("silent! bdelete")
    end
end, opts)
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
_G.term_buf = nil
_G.term_win = nil
_G.toggle_terminal = function()
  if _G.term_win and vim.api.nvim_win_is_valid(_G.term_win) then
    vim.api.nvim_win_close(_G.term_win, true)
    _G.term_win = nil
    return
  end
  vim.cmd("botright split")
  vim.cmd("resize 10")
  if _G.term_buf and vim.api.nvim_buf_is_valid(_G.term_buf) then
    vim.api.nvim_set_current_buf(_G.term_buf)
  else
    vim.cmd("term")
    _G.term_buf = vim.api.nvim_get_current_buf()
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
  end
  _G.term_win = vim.api.nvim_get_current_win()
end
keymap('n', '<C-t>', '<cmd>lua toggle_terminal()<CR>', opts)
keymap('t', '<C-t>', [[<C-\><C-n><cmd>lua toggle_terminal()<CR>]], opts)
keymap('t', '<Esc>', [[<C-\><C-n>]], opts)
