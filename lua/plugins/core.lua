-- ============================================================
-- plugins/core.lua — Plugin Inti (Non-LSP)
-- Colorscheme, Treesitter, UI, Git, Fuzzy Finder, dsb
-- ============================================================

return {

  -- ──────────────────────────────────────────────────────────
  -- 1. COLORSCHEME — Catppuccin Mocha
  -- lazy=false + priority tinggi agar dimuat pertama
  -- ──────────────────────────────────────────────────────────
  {
    "folke/tokyonight.nvim",
    lazy    = false, -- load saat startup
    priority = 1000,  -- load pertama
    opts = {
      style       = "night",  -- night | storm | day | moon
      transparent = false,
      terminal_colors = true,
      styles = {
        comments    = { italic = false }, -- italic bisa lambat di Termux
        keywords    = { italic = false },
        sidebars    = "dark",
        floats      = "dark",
      },
      -- Kurangi dim_inactive untuk performa
      dim_inactive = false,
      lualine_bold = false,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 2. ICONS — nvim-web-devicons
  -- Digunakan oleh nvim-tree, lualine, fzf-lua
  -- ──────────────────────────────────────────────────────────
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true, -- Dimuat oleh plugin lain sebagai dependency
  },

  -- ──────────────────────────────────────────────────────────
  -- 3. TREESITTER — Syntax highlighting & parsing
  -- Branch: master (sesuai permintaan)
  -- ──────────────────────────────────────────────────────────
  {
    'nvim-treesitter/nvim-treesitter',
    branch  = 'main',
    commit = vim.fn.has("nvim-0.12") == 0 and "7caec274fd19c12b55902a5b795100d21531391f" or nil,
    build   = ':TSUpdate',
    event   = { 'BufReadPost', 'BufNewFile' }, -- Lazy: muat saat buka file
    dependencies = {
      -- Context: tampilkan fungsi/class aktif di baris atas
      -- { 'nvim-treesitter/nvim-treesitter-context', opts = { max_lines = 3 } },
    },
    opts = {
      -- Bahasa yang diinstall otomatis
      ensure_installed = {
        'lua', 'vimdoc', 'vim',          -- Neovim itself
        'php', 'phpdoc', 'blade',        -- PHP
        'go', 'gomod', 'gosum',          -- Go
        'svelte', 'html', 'css', 'vue',  -- Svelte/Web
        'typescript', 'javascript', 'tsx', 'jsdoc', -- TypeScript
        'rust', 'ron',                   -- Rust
        'json', 'yaml', 'toml',          -- Config files
        'bash', 'markdown', 'markdown_inline', -- Misc
        'regex', 'comment',              -- Utilities
      },
      sync_install = false, -- Jangan blokir saat install
      auto_install = true,  -- Install otomatis parser yang belum ada

      -- ── Highlight ──────────────────────────────────────
      highlight = {
        enable = true,
        -- Nonaktifkan untuk file besar (performa)
        disable = function(_, buf)
          return vim.b[buf] and vim.b[buf].big_file
        end,
        -- Gunakan treesitter saja, jangan kombinasi dengan regex syntax
        additional_vim_regex_highlighting = false,
      },

      -- ── Indentasi berbasis Treesitter ──────────────────
      indent = {
        enable  = true,
        disable = { 'go', 'python' }, -- Go & python punya indent sendiri
      },

      -- ── Incremental Selection ─────────────────────────
      -- gnn = mulai seleksi dari node kursor
      -- grn = perluas seleksi ke node induk
      -- grm = perkecil seleksi ke node child
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection    = 'gnn',
          node_incremental  = 'grn',
          scope_incremental = 'grc',
          node_decremental  = 'grm',
        },
      },
    },
    config = function(_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter').setup(opts)
      require('nvim-treesitter').install(opts.ensure_installed)

      vim.api.nvim_create_autocmd('FileType', {
        desc = "Memuat Highlight Syntax TS dan indentasi terbaru 2026",
        pattern = opts.ensure_installed,
        callback = function(args)
          -- Ini menggantikan highlight = { enable = true } 
          vim.treesitter.start(args.buf) 
          
          -- Ini menggantikan indent = { enable = true }
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 4. FILE SIDEBAR — nvim-tree
  -- Sidebar file explorer, ganti netrw
  -- ──────────────────────────────────────────────────────────
  {
    'nvim-tree/nvim-tree.lua',
    cmd          = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    keys = {
      { '<leader>e',  '<cmd>NvimTreeToggle<cr>',   desc = 'Toggle File Explorer' },
      { '<leader>fe', '<cmd>NvimTreeFocus<cr>',    desc = 'Fokus File Explorer' },
      { '<leader>fE', '<cmd>NvimTreeFindFile<cr>', desc = 'Temukan File di Explorer' },
    },
    config = function()
      require('nvim-tree').setup({
        -- Auto-tutup jika hanya nvim-tree yang tersisa
        on_attach = function(bufnr)
          local api  = require('nvim-tree.api')
          local opts = function(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true }
          end

          -- Keymap default
          api.config.mappings.default_on_attach(bufnr)

          -- Tambahan keymap
          vim.keymap.set('n', '<CR>',  api.node.open.edit,      opts('Buka'))
          vim.keymap.set('n', 'v',     api.node.open.vertical,  opts('Buka Vertikal'))
          vim.keymap.set('n', 's',     api.node.open.horizontal,opts('Buka Horizontal'))
          vim.keymap.set('n', '?',     api.tree.toggle_help,    opts('Bantuan'))
        end,

        view = {
          width        = 30,
          side         = 'left',
          preserve_window_proportions = true,
        },

        renderer = {
          group_empty  = true,   -- Tampilkan folder kosong dalam satu baris
          highlight_git = true,
          icons = {
            show = { file = true, folder = true, folder_arrow = true, git = true },
            glyphs = {
              git = {
                unstaged  = '✗',
                staged    = '✓',
                unmerged  = '',
                renamed   = '➜',
                untracked = '★',
                deleted   = '',
                ignored   = '◌',
              },
            },
          },
        },

        filters = {
          dotfiles = true,     -- Tampilkan dotfiles
          custom   = { '^.git$', 'node_modules', '^.cache$' },
        },

        git = {
          enable  = true,
          ignore  = true,       -- Hormati .gitignore
          timeout = 300,
        },

        actions = {
          open_file = {
            quit_on_open = false, -- Jangan tutup tree saat buka file
            resize_window = true,
          },
        },

        -- Tutup otomatis jika satu-satunya window tersisa
        hijack_cursor   = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 5. STATUSLINE — Lualine
  -- Informasi: mode, git, LSP, diagnostic, filetype, lokasi
  -- ──────────────────────────────────────────────────────────
  {
    'nvim-lualine/lualine.nvim',
    event        = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      -- Komponen LSP: tampilkan nama client yang aktif
      local function lsp_clients()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then return '' end
        local names = {}
        for _, c in ipairs(clients) do
          -- Hanya tampilkan jika bukan 'null-ls' atau 'copilot'
          if c.name ~= 'null-ls' and c.name ~= 'copilot' then
            table.insert(names, c.name)
          end
        end
        if #names == 0 then return '' end
        return '󰒍 ' .. table.concat(names, '+')
      end

      -- Icon sesuai mode
      local mode_icons = {
        NORMAL   = '󱃖 ',
        INSERT   = '󰏫 ',
        VISUAL   = '󰒉 ',
        ['V-LINE']  = '󰒉 ',
        ['V-BLOCK'] = '󰒉 ',
        COMMAND  = '󰘳 ',
        REPLACE  = '󱇡 ',
        TERMINAL = ' ',
        SELECT   = '󱡅 ',
      }

      require('lualine').setup({
        options = {
          icons_enabled         = true,
          theme                 = 'tokyonight',
          -- Gunakan separator powerline untuk tampilan modern
          component_separators  = { left = '', right = '' },
          section_separators    = { left = '', right = '' },
          disabled_filetypes = {
            statusline = { 'NvimTree', 'lazy', 'mason', 'TelescopePrompt' },
          },
          globalstatus = true, -- Satu statusline global (laststatus=3)
          refresh = {
            statusline = 1000, -- Update setiap 1 detik
          },
        },

        sections = {
          -- Kiri 1: Mode dengan icon
          lualine_a = {{
            'mode',
            fmt = function(str)
              return (mode_icons[str] or '') .. str
            end,
          }},

          -- Kiri 2: Git branch & diff
          lualine_b = {
            { 'branch', icon = ' ' },
            {
              'diff',
              symbols  = { added = ' ', modified = ' ', removed = ' ' },
              colored  = true,
            },
          },

          -- Kiri 3: Nama file dengan status modifikasi
          lualine_c = {{
            'filename',
            path    = 1,    -- 0=nama saja, 1=relatif, 2=absolut
            symbols = {
              modified = '  ',
              readonly = ' ',
              unnamed  = '[Tanpa Nama]',
              newfile  = '[File Baru]',
            },
          }},

          -- Kanan 1: LSP clients & Diagnostics
          lualine_x = {
            { lsp_clients, color = { fg = '#89b4fa' }},
            {
              'diagnostics',
              sources  = { 'nvim_lsp' },
              sections = { 'error', 'warn', 'info', 'hint' },
              symbols  = { error = ' ', warn = ' ', info = ' ', hint = '󰠠 ' },
              colored  = true,
            },
          },

          -- Kanan 2: Filetype dengan icon
          lualine_y = {
            { 'filetype', icon_only = false },
          },

          -- Kanan 3: Posisi kursor
          lualine_z = {
            { 'location' },
            { 'progress' },
          },
        },

        -- Window yang tidak aktif: tampilkan minimal
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 6. WHICH-KEY — Panduan Keymap
  -- Tampilkan daftar keymap dalam popup
  -- ──────────────────────────────────────────────────────────
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'modern',
      delay  = 400,     -- Tampilkan popup setelah 400ms (hemat render)
      notify = false,   -- Jangan notifikasi key yang tidak ada mapping
      plugins = {
        marks     = true,
        registers = true,
        spelling  = { enabled = false },
      },
      win = {
        border  = 'rounded',
        padding = { 1, 2 },
      },
      layout = {
        width  = { min = 20 },
        height = { min = 4 },
        spacing = 3,
      },
      icons = {
        breadcrumb = '»',
        separator  = '➜',
        group      = '+',
        ellipsis   = '…',
        rules      = false, -- Gunakan icons dari spec, bukan auto-detect
      },
    },
    config = function(_, opts)
      local wk = require('which-key')
      wk.setup(opts)

      -- ── Definisi Group & Keymap ───────────────────────────
      wk.add({
        -- ── Group Definitions ───────────────────────────────
        { '<leader>b',  group = '󰓩 Buffer' },
        { '<leader>c',  group = ' Code' },
        { '<leader>f',  group = ' File/Find' },
        { '<leader>g',  group = ' Git' },
        { '<leader>gh', group = ' Hunks Git' },
        { '<leader>l',  group = '󰒍 LSP' },
        { '<leader>q',  group = '  QuickFix' },
        { '<leader>s',  group = ' Search' },
        { '<leader>t',  group = ' Terminal' },
        { '<leader>u',  group = ' UI Toggle' },
        { '<leader>w',  group = ' Window' },

        -- ── Buffer ──────────────────────────────────────────
        { '<leader>bd', function() require('config.utils').close_buffer() end,
          desc = 'Hapus Buffer' },
        { '<leader>bn', '<cmd>bnext<cr>',     desc = 'Buffer Berikutnya' },
        { '<leader>bp', '<cmd>bprev<cr>',     desc = 'Buffer Sebelumnya' },
        { '<leader>bD', '<cmd>%bdelete|edit#|bdelete#<cr>',
          desc = 'Hapus Semua Buffer Lain' },
        { '<leader>ba', '<cmd>bufdo bdelete<cr>',
          desc = 'Hapus Semua Buffer' },

        -- ── File/Find (fzf-lua) ─────────────────────────────
        { '<leader>ff', function() require('fzf-lua').files() end,
          desc = 'Cari File' },
        { '<leader>fg', function() require('fzf-lua').live_grep() end,
          desc = 'Cari Teks (Grep)' },
        { '<leader>fb', function() require('fzf-lua').buffers() end,
          desc = 'Cari Buffer' },
        { '<leader>fr', function() require('fzf-lua').oldfiles() end,
          desc = 'File Terakhir Dibuka' },
        { '<leader>fh', function() require('fzf-lua').help_tags() end,
          desc = 'Cari Bantuan' },
        { '<leader>fS', function() require('config.utils').save_as() end,
          desc = 'Simpan Sebagai (Save As)' },
        { '<leader>fw', function() require('fzf-lua').grep_cword() end,
          desc = 'Cari Kata di Kursor' },

        -- ── Git (lazygit + gitsigns) ─────────────────────────
        { '<leader>gg', function() require('config.utils').open_lazygit() end,
          desc = 'Lazygit' },
        { '<leader>ghs', function() require('gitsigns').stage_hunk() end,
          desc = 'Stage Hunk' },
        { '<leader>ghr', function() require('gitsigns').reset_hunk() end,
          desc = 'Reset Hunk' },
        { '<leader>ghb', function() require('gitsigns').blame_line({ full = true }) end,
          desc = 'Blame Baris' },
        { '<leader>ghd', function() require('gitsigns').diffthis() end,
          desc = 'Diff File Ini' },
        { '<leader>ghp', function() require('gitsigns').preview_hunk() end,
          desc = 'Preview Hunk' },
        { '<leader>ghS', function() require('gitsigns').stage_buffer() end,
          desc = 'Stage Seluruh Buffer' },
        { '<leader>ghR', function() require('gitsigns').reset_buffer() end,
          desc = 'Reset Seluruh Buffer' },
        -- Navigate hunks
        { ']h', function() require('gitsigns').next_hunk() end,
          desc = 'Hunk Git Berikutnya' },
        { '[h', function() require('gitsigns').prev_hunk() end,
          desc = 'Hunk Git Sebelumnya' },

        -- ── LSP (diisi dari plugins/lsp.lua, ini hanya yang global) ─
        { '<leader>li', '<cmd>LspInfo<cr>',    desc = 'LSP Info' },
        { '<leader>lr', '<cmd>LspRestart<cr>', desc = 'LSP Restart' },
        { '<leader>ll', '<cmd>LspLog<cr>',     desc = 'LSP Log' },
        { '<leader>ld', function() vim.diagnostic.open_float() end,
          desc = 'Diagnostic Float' },
        { '<leader>lq', function() vim.diagnostic.setloclist() end,
          desc = 'Daftar Diagnostic' },

        -- ── Search ──────────────────────────────────────────
        { '<leader>ss', function() require('fzf-lua').lsp_document_symbols() end,
          desc = 'Simbol Dokumen' },
        { '<leader>sS', function() require('fzf-lua').lsp_workspace_symbols() end,
          desc = 'Simbol Workspace' },
        { '<leader>sk', function() require('fzf-lua').keymaps() end,
          desc = 'Cari Keymap' },
        { '<leader>sc', function() require('fzf-lua').commands() end,
          desc = 'Cari Command' },
        { '<leader>sd', function() require('fzf-lua').diagnostics_document() end,
          desc = 'Diagnostic Dokumen' },

        -- ── Terminal ────────────────────────────────────────
        { '<leader>tt', function() require('config.utils').toggle_float_term() end,
          desc = 'Toggle Terminal Floating' },
        { '<leader>th', function() require('config.utils').toggle_term('horizontal') end,
          desc = 'Terminal Horizontal' },
        { '<leader>tv', function() require('config.utils').toggle_term('vertical') end,
          desc = 'Terminal Vertical' },


        -- ── UI Toggles ──────────────────────────────────────
        { '<leader>un', function()
            local ok, mn = pcall(require, 'mini.notify')
            if ok then mn.show_history() end
          end, desc = 'Riwayat Notifikasi' },
        { '<leader>uw', '<cmd>set wrap!<cr>',           desc = 'Toggle Wrap' },
        { '<leader>ul', '<cmd>set relativenumber!<cr>', desc = 'Toggle Relative Number' },
        { '<leader>us', '<cmd>set spell!<cr>',          desc = 'Toggle Spell Check' },
        { '<leader>ue', '<cmd>NvimTreeToggle<cr>',      desc = 'Toggle File Explorer' },
        { '<leader>uh', function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }),
              { bufnr = 0 }
            )
          end, desc = 'Toggle Inlay Hints' },

        -- ── Window ──────────────────────────────────────────
        { '<leader>ws', '<cmd>split<cr>',   desc = 'Split Horizontal' },
        { '<leader>wv', '<cmd>vsplit<cr>',  desc = 'Split Vertikal' },
        { '<leader>wc', '<cmd>close<cr>',   desc = 'Tutup Window' },
        { '<leader>wo', '<cmd>only<cr>',    desc = 'Tutup Window Lain' },
        { '<leader>ww', '<C-w>w',           desc = 'Switch Window' },
        { '<leader>wh', '<C-w>h',           desc = 'Window Kiri' },
        { '<leader>wj', '<C-w>j',           desc = 'Window Bawah' },
        { '<leader>wk', '<C-w>k',           desc = 'Window Atas' },
        { '<leader>wl', '<C-w>l',           desc = 'Window Kanan' },
        { '<leader>w=', '<C-w>=',           desc = 'Equalise Windows' },

        -- ── Shortcut Find (Ctrl+P = Sublime Open File) ──────
        { '<C-p>', function() require('fzf-lua').files() end,
          mode = 'n', desc = 'Cari File' },
        { '<A-p>', function() require('fzf-lua').live_grep() end,
          mode = 'n', desc = 'Cari Teks (Grep)' },

        -- ── Replace / Find (Ctrl+H = Sublime) ───────────────
        { '<C-h>', nil, desc = '' }, -- Override jangan tampil (sudah dipakai window nav)
        { '<leader>sh', ':%s/<C-r><C-w>/<C-r><C-w>/gc<Left><Left><Left>',
          desc = 'Replace Kata di Kursor' },
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 7. FUZZY FINDER — fzf-lua
  -- Lebih ringan dari telescope, cocok untuk Termux
  -- Syarat: pkg install fzf
  -- ──────────────────────────────────────────────────────────
  {
    'ibhagwan/fzf-lua',
    cmd  = 'FzfLua',
    keys = {
      { '<C-p>', function() require('fzf-lua').files() end,      desc = 'Cari File' },
      { '<A-p>', function() require('fzf-lua').live_grep() end,  desc = 'Cari Teks (Grep)' },
      { '<leader>ff', function() require('fzf-lua').files() end, desc = 'Cari File' },
    },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      -- Gunakan fzf native (pkg install fzf di Termux)
      fzf_bin = 'fzf',
      winopts = {
        border  = 'rounded',
        height  = 0.85,
        width   = 0.85,
        preview = {
          border     = 'border',
          wrap       = 'nowrap',
          -- hidden     = 'nohidden',
          -- vertical   = 'down:45%',
          -- horizontal = 'right:50%',
          -- layout     = 'flex',
          -- flip_columns = 100,
        },
      },
      fzf_opts = {
        ['--ansi']       = true,
        ['--layout']     = 'reverse',
        ['--border']     = 'none',
        ['--info']       = 'inline',
      },
      keymap = {
        builtin = {
          ['<C-d>'] = 'preview-page-down',
          ['<C-u>'] = 'preview-page-up',
          ['<C-f>'] = 'preview-page-down',
          ['<C-b>'] = 'preview-page-up',
        },
      },
      -- Konfigurasi per picker
      files = {
        prompt     = 'Files❯ ',
        hidden     = false,
        git_icons  = true,
        file_icons = true,
        -- Gunakan fd jika tersedia (pkg install fd), fallback ke find
        cmd = vim.fn.executable('fd') == 1
          and 'fd --type f --hidden --follow --exclude .git'
          or  nil,
      },
      grep = {
        rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden -g "!.git"',
      },
    },
  },

  -- ──────────────────────────────────────────────────────────
  -- 8. NOTIFIKASI FLOATING — mini.notify
  -- Menggantikan vim.notify dengan notifikasi floating
  -- ──────────────────────────────────────────────────────────
  {
    'echasnovski/mini.notify',
    version = false,
    event   = 'VeryLazy',
    config  = function()
      local mn = require('mini.notify')
      mn.setup({
        content = {
          -- Tambahkan icon sesuai level
          format = function(notif)
            local level_icons = {
              ERROR = ' ',
              WARN  = ' ',
              INFO  = ' ',
              DEBUG = '󰃤 ',
              TRACE = '󰔚 ',
            }
            local icon = level_icons[notif.level] or ''
            return icon .. notif.msg
          end,
        },
        window = {
          config = {
            border  = 'rounded',
            zindex  = 200,     -- Di atas semua window lain
          },
          max_width_share = 0.45, -- Maksimal 45% lebar layar
          winblend        = 20,   -- Sedikit transparan
        },
        lsp_progress = {
          enable        = true,  -- Tampilkan progress LSP
          duration_last = 1000,  -- Tampilkan 1 detik setelah selesai
        },
      })
      -- Override vim.notify global
      vim.notify = mn.make_notify()
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 9. AUTO PAIRS — mini.pairs
  -- Otomatis tutup bracket, quote, dll
  -- ──────────────────────────────────────────────────────────
  {
    'echasnovski/mini.pairs',
    version = false,
    event   = 'InsertEnter',
    opts    = {
      -- Karakter yang di-pair secara otomatis
      mappings = {
        ['(']  = { action = 'open',  pair = '()', neigh_pattern = '[^\\].' },
        ['[']  = { action = 'open',  pair = '[]', neigh_pattern = '[^\\].' },
        ['{']  = { action = 'open',  pair = '{}', neigh_pattern = '[^\\].' },
        [')']  = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']']  = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}']  = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
        ['"']  = { action = 'closeopen', pair = '""', neigh_pattern = '[^\\].', register = { cr = false } },
        ["'"]  = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`']  = { action = 'closeopen', pair = '``', neigh_pattern = '[^\\].', register = { cr = false } },
      },
    },
  },

  -- ──────────────────────────────────────────────────────────
  -- 10. GIT SIGNS — gitsigns.nvim
  -- Tampilkan perubahan git di sign column
  -- ──────────────────────────────────────────────────────────
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts  = {
      signs = {
        add          = { text = '▎' },
        change       = { text = '▎' },
        delete       = { text = '' },
        topdelete    = { text = '' },
        changedelete = { text = '▎' },
        untracked    = { text = '┆' },
      },
      signs_staged_enable = true,
      signcolumn          = true,
      numhl               = false,
      linehl              = false,
      word_diff           = false,
      attach_to_untracked = false,

      -- Preview hunk saat hover (CursorHold)
      preview_config = {
        border   = 'rounded',
        style    = 'minimal',
        relative = 'cursor',
        row      = 0,
        col      = 1,
      },
    },
  },

  -- ──────────────────────────────────────────────────────────
  -- 11. FORMATTER — conform.nvim
  -- Format on demand (bukan on-save agar tidak lag di Termux)
  -- ──────────────────────────────────────────────────────────
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd   = 'ConformInfo',
    keys  = {
      { '<leader>cf', function()
          require('conform').format({ async = true, lsp_fallback = true })
        end, desc = 'Format File' },
      { '<leader>lf', function()
          require('conform').format({ async = true, lsp_fallback = true })
        end, desc = 'Format (LSP)' },
    },
    opts = {
      formatters_by_ft = {
        -- PHP: pint (install via composer global: composer global require laravel/pint)
        php         = { 'pint' },
        blade       = { 'pint' },
        -- Go: gofmt + goimports (via termux: pkg install golang)
        go          = { 'gofmt', 'goimports' },
        -- TypeScript/JavaScript/Svelte: prettier
        typescript  = { 'prettier' },
        javascript  = { 'prettier' },
        typescriptreact = { 'prettier' },
        javascriptreact = { 'prettier' },
        svelte      = { 'prettier' },
        html        = { 'prettier' },
        css         = { 'prettier' },
        json        = { 'prettier' },
        yaml        = { 'prettier' },
        -- Rust: rustfmt (via termux: pkg install rust)
        rust        = { 'rustfmt' },
        -- Lua: stylua (install via mason)
      },

      -- Formatter kustom
      formatters = {
        -- Prettier: cari config dari root project secara otomatis
        prettier = {
          -- Jika tidak ada .prettierrc, gunakan opsi default ini
          prepend_args = function(_, ctx)
            -- Cek apakah project punya config prettier sendiri
            local has_config = vim.fn.filereadable(ctx.dirname .. "/.prettierrc") == 1
              or vim.fn.filereadable(ctx.dirname .. "/.prettierrc.json") == 1
              or vim.fn.filereadable(ctx.dirname .. "/prettier.config.js") == 1

            if not has_config then
              return {
                "--tab-width", "2",
                "--single-quote",
                "--trailing-comma", "es5",
                "--print-width", "100",
              }
            end
            return {}
          end,
        },

        -- Pint untuk PHP (Laravel)
        pint = {
          command = function()
            local local_pint = vim.fn.getcwd() .. "/vendor/bin/pint"
            if vim.fn.filereadable(local_pint) == 1 then
              return local_pint   -- pakai pint dari project (rekomendasi)
            end
            return "pint"         -- pakai pint global
          end,
        },
      },

      -- Jangan format otomatis saat save (kita format manual via keymap)
      -- Jika ingin format otomatis, uncomment:
      -- format_on_save = { timeout_ms = 3000, lsp_fallback = true },
      notify_on_error = true,
    },
  },

}
