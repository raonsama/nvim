-- ============================================================
-- NEOVIM CONFIG — lua/plugins/init.lua
-- Target : Termux Android, Neovim 0.11+
-- Semua plugin non-kritikal menggunakan lazy loading.
-- ============================================================
return {

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [MANDATORY] COLORSCHEME                        ║
  -- ║  lazy=false & priority=1000: harus di-load pertama     ║
  -- ║  sebelum plugin lain agar tidak ada flash warna.       ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      require("tokyonight").setup({
        style       = "night",
        transparent = true,   -- background transparan (cocok untuk Termux)
      })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] GITSIGNS                            ║
  -- ║  Tampilkan status git di sign column (added/changed/   ║
  -- ║  removed). Lazy: load saat buka file pertama kali.     ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "lewis6991/gitsigns.nvim",
    event  = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signcolumn         = true,
        current_line_blame = false,  -- matikan blame per baris (berat di ARM)

        -- update_debounce: tunggu 300ms setelah ketikan terakhir
        -- sebelum re-run git diff. Default 100ms terlalu agresif di Termux.
        update_debounce = 300,

        watch_gitdir = {
          follow_files = true,
          interval     = 2000,  -- cek perubahan git dir tiap 2 detik (default 1000)
        },
      })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [MANDATORY] TREESITTER                         ║
  -- ║  Syntax highlight & indent berbasis AST.               ║
  -- ║  Lazy: load setelah buffer dibaca (BufReadPost).       ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        -- ensure_installed: parser yang auto-download saat belum ada.
        -- Dipakai oleh autocmd FileType di bawah untuk highlight & indent.
        ensure_installed = {
          "php", "typescript", "tsx", "javascript",
          "html", "css", "lua", "json", "bash", "yaml", "xml",
          "vim", "vimdoc", "regex", "query", "diff",
        },
      })

      -- Cache hasil pengecekan parser & query per bahasa.
      -- Tanpa cache: dicek ulang setiap kali buka file dengan filetype sama.
      -- Dengan cache: dicek sekali per sesi → hemat CPU di ARM.
      local ts_cache = {}

      local function ts_have(buf, lang, query_name)
        local key = lang .. ":" .. (query_name or "")
        if ts_cache[key] ~= nil then return ts_cache[key] end

        -- Cek apakah parser bahasa tersedia
        local ok = pcall(vim.treesitter.get_parser, buf, lang)
        if not ok then
          ts_cache[key] = false
          return false
        end

        -- Cek apakah file query tersedia (highlights / indents / dll)
        if query_name then
          local q = vim.treesitter.query.get(lang, query_name)
          if not q then
            ts_cache[key] = false
            return false
          end
        end

        ts_cache[key] = true
        return true
      end

      vim.api.nvim_create_autocmd("FileType", {
        group    = vim.api.nvim_create_augroup("ts_setup", { clear = true }),
        callback = function(ev)
          -- Skip buffer khusus: terminal, NvimTree, Lazy, Mason, dll
          if vim.bo[ev.buf].buftype ~= "" then return end
          -- Skip file besar (sudah ditangani di options.lua)
          if vim.b[ev.buf].large_file then return end

          -- Dapatkan nama bahasa treesitter dari filetype
          -- (misal: filetype "typescript" → lang "typescript")
          local lang = vim.treesitter.language.get_lang(ev.match)
          if not lang then return end

          -- Aktifkan highlight jika parser + highlights query tersedia
          if ts_have(ev.buf, lang, "highlights") then
            pcall(vim.treesitter.start, ev.buf)
          end

          -- Aktifkan indent jika parser + indents query tersedia.
          -- Jika tidak ada → fallback ke smartindent bawaan Neovim
          -- (di-set via autoindent+smartindent di options.lua).
          if ts_have(ev.buf, lang, "indents") then
            vim.bo[ev.buf].indentexpr =
              "v:lua.require'nvim-treesitter'.indentexpr()"
          else
            vim.bo[ev.buf].indentexpr = ""  -- aktifkan smartindent sebagai fallback
          end
        end,
      })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [MANDATORY] LSP + MASON + CMP                  ║
  -- ║  Language Server Protocol untuk autocomplete,          ║
  -- ║  diagnostik, go-to-definition, dll.                    ║
  -- ║  Lazy: load saat buka file pertama kali.               ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim" },           -- UI installer LSP/linter/formatter
      { "mason-org/mason-lspconfig.nvim" }, -- jembatan mason ↔ lspconfig
      "hrsh7th/nvim-cmp",                   -- mesin autocomplete
      "hrsh7th/cmp-nvim-lsp",              -- source: LSP
      "hrsh7th/cmp-buffer",                -- source: kata di buffer aktif
      "hrsh7th/cmp-path",                  -- source: path file/direktori
      "L3MON4D3/LuaSnip",                  -- snippet engine
      "saadparwaiz1/cmp_luasnip",          -- jembatan LuaSnip ↔ cmp
    },
    config = function()
      -- Setup Mason (UI untuk install LSP, linter, formatter)
      require("mason").setup({ ui = { border = "rounded" } })

      -- ── KONFIGURASI INTELEPHENSE (PHP LSP) ──────────────────
      -- BUG FIX: vendor/** harus di-exclude!
      -- Tanpa ini, intelephense akan mengindeks ribuan file di vendor/
      -- → freeze selama menit-menit saat buka project Laravel/Symfony.
      vim.lsp.config('intelephense', {
        settings = {
          intelephense = {
            files = {
              exclude = {
                "**/.git/**",           -- git internals
                "**/node_modules/**",   -- JS dependencies
                "**/vendor/**",         -- PHP dependencies (PALING PENTING!)
                "**/storage/**",        -- Laravel storage
                "**/public/build/**",   -- asset build output
                "**/public/hot/**",     -- Vite HMR files
                "**/*.min.js",          -- JS minified
                "**/*.min.css",         -- CSS minified
              },
              -- maxSize: batas ukuran file yang di-index (bytes).
              -- Naikkan sedikit agar file besar yang valid tetap ter-index.
              maxSize = 1000000,
            },
            telemetry = { enabled = false },  -- matikan telemetry (hemat network)
            completion = {
              -- Jangan tulis namespace penuh untuk konstanta global → lebih ringkas
              fullyQualifyGlobalConstantsAndFunctions = false,
            },
          },
        },
      })

      -- ── CAPABILITIES (berlaku untuk SEMUA LSP) ───────────────
      -- Beritahu LSP fitur autocomplete apa yang didukung Neovim.
      -- Wildcard '*' = semua LSP yang attach akan dapat capabilities ini.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config('*', { capabilities = capabilities })

      -- ── AUTO-INSTALL LSP ─────────────────────────────────────
      -- Mason akan auto-install LSP yang belum ada saat pertama buka.
      -- automatic_enable=true (default) → LSP langsung aktif setelah install.
      require("mason-lspconfig").setup({
        ensure_installed = { "intelephense", "ts_ls", "tailwindcss" },
      })

      -- ── AUTOCOMPLETE (CMP) ───────────────────────────────────
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },

        -- Tuning performa CMP untuk ARM:
        performance = {
          debounce         = 60,   -- tunggu 60ms setelah ketikan sebelum query
          throttle         = 30,   -- minimum 30ms antar render popup
          fetching_timeout = 500,  -- timeout per source LSP
          max_view_entries = 10,   -- tampilkan max 10 item (default 200!)
        },

        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),              -- paksa buka popup
          ['<CR>']      = cmp.mapping.confirm({ select = true }), -- konfirmasi pilihan
          ['<Tab>']     = cmp.mapping.select_next_item(),      -- navigasi bawah
          ['<S-Tab>']   = cmp.mapping.select_prev_item(),      -- navigasi atas
          ['<C-e>']     = cmp.mapping.abort(),                 -- tutup popup
          ['<Esc>']     = cmp.mapping.abort(),                 -- tutup popup (alternatif)
        }),

        -- Sources dikelompokkan: group 1 dicoba dulu, jika kosong baru group 2.
        sources = cmp.config.sources({
          { name = 'nvim_lsp', max_item_count = 15 },  -- saran dari LSP
          { name = 'luasnip',  max_item_count = 5 },   -- snippet
        }, {
          { name = 'buffer', max_item_count = 5, keyword_length = 3 }, -- kata di buffer
          { name = 'path',   max_item_count = 5 },                     -- path file
        }),
      })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] NVIM-TREE (File Explorer)           ║
  -- ║  Lazy: load hanya saat command/keymap dipanggil.       ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd  = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
    keys = { { "<C-b>", "<cmd>NvimTreeToggle<CR>" } },
    config = function()
      require("nvim-tree").setup({
        hijack_netrw       = false,         -- netrw sudah dimatikan di init.lua
        sync_root_with_cwd = true,          -- root tree ikuti cwd Neovim

        view = {
          adaptive_size = false,  -- lebar fixed (adaptive_size=true re-calc tiap file berubah)
          width         = 30,
        },

        renderer = {
          group_empty = true,  -- folder kosong di-group dalam satu baris
        },

        filters = {
          dotfiles = true,  -- sembunyikan file dot (.env, .git, dll) secara default
        },

        update_focused_file = {
          enable      = true,
          update_root = true,  -- update root tree saat ganti buffer
        },
      })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] TELESCOPE (Fuzzy Finder)            ║
  -- ║  Cari file, teks, buffer, dll.                         ║
  -- ║  Lazy: load saat command/keymap dipanggil.             ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "nvim-telescope/telescope.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd  = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<CR>" },
      { "<C-f>", "<cmd>Telescope live_grep<CR>" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          -- Exclude folder berat dari pencarian.
          -- Tanpa ini, live_grep akan scan vendor/ dll → sangat lambat.
          file_ignore_patterns = {
            "vendor/.*",
            "node_modules/.*",
            "%.git/.*",
            "storage/.*",
            "public/build/.*",
            "%.min%.js",
            "%.min%.css",
            "%.lock",
          },

          -- Layout vertikal lebih ringan di tablet
          layout_strategy = "vertical",
          layout_config   = { height = 0.8, width = 0.7 },

          -- Update judul preview secara dinamis (ringan)
          dynamic_preview_title = true,
        },

        pickers = {
          find_files = {
            -- fd jauh lebih cepat dari find bawaan di Termux/ARM.
            -- Install: pkg install fd
            find_command = { "fd", "--type", "f", "--hidden", "--strip-cwd-prefix" },
          },
          live_grep = {
            -- 1 match per file cukup untuk navigasi ke lokasi kode.
            -- Mengurangi output ripgrep secara signifikan.
            additional_args = { "--max-count=1" },
          },
        },
      })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] SPECTRE (Find & Replace)            ║
  -- ║  Find & replace lintas file dengan preview.            ║
  -- ║  Lazy: load saat keymap <leader>h dipanggil.           ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "nvim-pack/nvim-spectre",
    keys   = { { "<leader>h", function() require('spectre').toggle() end } },
    config = function()
      require('spectre').setup({ open_cmd = 'vnew' })
    end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] COMMENT.NVIM                        ║
  -- ║  Toggle komentar dengan Ctrl+/.                        ║
  -- ║  Lazy: load setelah file dibaca.                       ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "numToStr/Comment.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function() require('Comment').setup() end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] AUTOPAIRS                           ║
  -- ║  Auto-tutup bracket, quote, dll saat mengetik.         ║
  -- ║  Lazy: load saat masuk Insert mode (paling efisien).   ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function() require("nvim-autopairs").setup() end,
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] LAZYGIT                             ║
  -- ║  UI git lengkap di dalam Neovim.                       ║
  -- ║  Lazy: load hanya saat command/keymap dipanggil.       ║
  -- ║  Requires: pkg install lazygit                         ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "kdheepak/lazygit.nvim",
    lazy = true,   -- eksplisit agar intent jelas (cmd sudah implisit lazy)
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  -- ╔════════════════════════════════════════════════════════╗
  -- ║         [OPTIONAL] CONFORM.NVIM (Formatter)            ║
  -- ║  Format kode dengan prettier (JS/TS/CSS/HTML) dan      ║
  -- ║  Laravel Pint (PHP).                                   ║
  -- ║                                                        ║
  -- ║  Install formatter di Termux:                          ║
  -- ║    npm install -g prettier                             ║
  -- ║    composer global require laravel/pint                ║
  -- ║                                                        ║
  -- ║  Atau via Mason: <leader>m → cari prettier / pint      ║
  -- ╚════════════════════════════════════════════════════════╝
  {
    "stevearc/conform.nvim",
    -- Lazy: load hanya saat keymap <leader>f dipanggil (bukan BufWritePre)
    -- karena format on save dimatikan → tidak perlu load saat simpan file.
    keys  = { { "<leader>f", desc = "Format file" } },
    config = function()
      require("conform").setup({

        -- Daftar formatter per filetype.
        -- Urutan = prioritas: coba pertama dulu, fallback ke berikutnya.
        formatters_by_ft = {
          -- PHP: coba pint dulu (Laravel), fallback ke php_cs_fixer
          php = { "pint", stop_after_first = true },

          -- JS/TS: prettier untuk semua varian
          javascript      = { "prettier" },
          typescript      = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },

          -- Web: prettier
          html = { "prettier" },
          css  = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },

          -- Lua: stylua (opsional, install via Mason)
          -- lua = { "stylua" },
        },

        -- Format on save DIMATIKAN — gunakan <leader>f untuk format manual.
        -- Ini mencegah lag saat Ctrl+S karena prettier/pint butuh
        -- beberapa detik saat pertama jalan di ARM.
        format_on_save = false,

        -- Konfigurasi khusus per formatter
        formatters = {
          -- Prettier: cari config dari root project secara otomatis
          prettier = {
            -- Jika tidak ada .prettierrc, gunakan opsi default ini
            prepend_args = function(_, ctx)
              -- Cek apakah project punya config prettier sendiri
              local has_config = vim.fn.filereadable(
                ctx.dirname .. "/.prettierrc"
              ) == 1 or vim.fn.filereadable(
                ctx.dirname .. "/.prettierrc.json"
              ) == 1 or vim.fn.filereadable(
                ctx.dirname .. "/prettier.config.js"
              ) == 1

              -- Jika tidak ada config → pakai default yang wajar
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

          -- Pint: cari pint dari vendor project dulu,
          -- fallback ke pint global jika tidak ada
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
      })
    end,
  },
}
