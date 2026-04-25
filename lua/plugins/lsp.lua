-- ============================================================
-- plugins/lsp.lua — LSP, Completion, dan Mason
-- Menggunakan vim.lsp.config (Neovim 0.11+ API baru)
-- Bahasa: PHP, Go, Svelte, TypeScript, TailwindCSS, Rust
-- ============================================================

return {

  -- ──────────────────────────────────────────────────────────
  -- 1. CMP-NVIM-LSP — Sumber completion dari LSP
  -- lazy=false agar capabilities tersedia sebelum LSP mulai
  -- ──────────────────────────────────────────────────────────
  {
    'hrsh7th/cmp-nvim-lsp',
    lazy = false,
  },

  -- ──────────────────────────────────────────────────────────
  -- 2. MASON — Installer LSP, Linter, Formatter
  -- ──────────────────────────────────────────────────────────
  {
    'mason-org/mason.nvim',
    cmd  = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUpdate' },
    lazy = false,
    opts = {
      ui = {
        border      = 'rounded',
        icons = {
          package_installed   = '✓',
          package_pending     = '➜',
          package_uninstalled = '✗',
        },
      },
      -- Direktori install disesuaikan Termux
      install_root_dir = vim.fn.stdpath('data') .. '/mason',
    },
    config = function(_, opts)
      require('mason').setup(opts)
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 3. MASON-LSPCONFIG — Jembatan Mason ↔ vim.lsp.config
  -- Menginstall server LSP via mason secara otomatis
  -- ──────────────────────────────────────────────────────────
  {
    'mason-org/mason-lspconfig.nvim',
    lazy         = false, -- Harus dimuat saat startup untuk auto-enable
    dependencies = {
      'mason-org/mason.nvim',
      'hrsh7th/cmp-nvim-lsp', -- Pastikan capabilities tersedia
    },
    config = function()
      -- ── Step 1: Set capabilities global SEBELUM server mulai ──
      -- cmp-nvim-lsp sudah dimuat (dependency), aman di-require
      local capabilities = require('cmp_nvim_lsp').default_capabilities(
        vim.lsp.protocol.make_client_capabilities()
      )

      -- Aktifkan snippet support (untuk LuaSnip)
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Set global: berlaku untuk SEMUA server LSP
      vim.lsp.config('*', {
        capabilities = capabilities,
      })

      -- ── Step 2: Konfigurasi setiap server LSP ──────────────

      -- ── PHP — Phpactor ─────────────────────────────────────
      -- Install via Mason: :MasonInstall phpactor
      vim.lsp.config('phpactor', {
        cmd       = { 'phpactor', 'language-server' },
        filetypes = { 'php' },
        root_markers = { 'composer.json', '.git', 'artisan' },
        -- init_options = {
        --   -- Daftarkan lisensi premium jika ada (opsional)
        --   -- licenceKey = 'LICENCE_KEY_ANDA',
        --   globalStoragePath = vim.fn.stdpath('data') .. '/intelephense',
        -- },
        -- settings = {
        --   intelephense = {
        --     files = {
        --       exclude = {
        --         "**/.git/**",
        --         "**/node_modules/**",
        --         "**/vendor/**/test*/**",
        --         "**/vendor/**/Tests/**",
        --         "**/vendor/**/spec/**",
        --         "**/storage/**",
        --         "**/public/build/**",
        --         "**/public/hot/**",
        --         "**/*.min.js",
        --         "**/*.min.css",
        --       },
        --       -- Perbesar batas ukuran file PHP
        --       maxSize      = 600000,
        --       associations = { '*.php', '*.blade.php', '*.phtml' },
        --     },
        --     stubs = {
        --       "apache", "bcmath", "bz2", "calendar", "Core", "ctype", "curl", "date", 
        --       "dom", "fileinfo", "filter", "gd", "hash", "iconv", "intl", "json", 
        --       "libxml", "mbstring", "openssl", "pcre", "PDO", "pdo_mysql", "Phar", 
        --       "Reflection", "session", "SimpleXML", "SPL", "standard", "tokenizer", 
        --       "xml", "xmlreader", "xmlwriter", "zip", "zlib", "wordpress", "phpunit",
        --     },
        --     -- environment = {
        --     --   phpVersion = '8.5.1', -- Sesuaikan versi PHP Anda
        --     -- },
        --     -- format = { enable = false }, -- Gunakan intelephense formatter
        --     diagnostics = { enable = true },
        --     completion = {
        --       insertUseDeclaration  = true, -- Auto-import use statement
        --       fullyQualifyGlobalConstantsAndFunctions = false,
        --     },
        --     phpdoc = { textFormat = 'text' },
        --   },
        -- },
      })

      -- ── TypeScript — typescript-language-server ────────────
      -- Install via Mason: :MasonInstall ts_ls
      vim.lsp.config('ts_ls', {
        cmd       = { 'typescript-language-server', '--stdio' },
        filetypes = {
          'javascript', 'javascriptreact', 'javascript.jsx',
          'typescript', 'typescriptreact', 'typescript.tsx',
        },
        root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints         = 'all',
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints          = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints  = true,
              includeInlayEnumMemberValueHints         = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints         = 'all',
              includeInlayVariableTypeHints          = true,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
        },
      })

      -- ── Svelte — svelte-language-server ───────────────────
      -- Install via Mason: :MasonInstall svelte-language-server
      vim.lsp.config('svelte', {
        cmd       = { 'svelteserver', '--stdio' },
        filetypes = { 'svelte' },
        root_markers = { 'svelte.config.js', 'svelte.config.ts', 'package.json' },
        settings = {
          svelte = {
            plugin = {
              html       = { completions = { enable = true, emmet = false } },
              svelte     = { defaultScriptLanguage = 'ts' },
              css        = { globals = '' },
              typescript = { diagnostics = { enable = true } },
            },
          },
        },
      })

      -- ── TailwindCSS — tailwindcss-language-server ─────────
      -- Install via Mason: :MasonInstall tailwindcss-language-server
      vim.lsp.config('tailwindcss', {
        cmd       = { 'tailwindcss-language-server', '--stdio' },
        filetypes = {
          'html', 'css', 'postcss',
          'javascript', 'javascriptreact',
          'typescript', 'typescriptreact',
          'svelte', 'blade',
        },
        root_markers = {
          'tailwind.config.js', 'tailwind.config.ts',
          'tailwind.config.cjs', 'tailwind.config.mjs',
          'package.json',
        },
        settings = {
          tailwindCSS = {
            validate            = true,
            lint = {
              cssConflict       = 'warning',
              invalidApply      = 'error',
              invalidScreen     = 'error',
              invalidVariant    = 'error',
              invalidConfigPath = 'error',
              invalidTailwindDirective = 'error',
              recommendedVariantOrder  = 'warning',
            },
            -- Class regex kustom (berguna untuk template string, dll)
            experimental = {
              classRegex = {
                'tw`([^`]*)',
                'tw="([^"]*)',
                "tw='([^']*)",
                'tw\\(([^)]*)',
                { 'clsx\\(([^)]*)\\)', "'([^']*)'" },
                { 'cva\\(([^)]*)\\)',  "'([^']*)'" },
                { 'cn\\(([^)]*)\\)',   "'([^']*)'" },
              },
            },
          },
        },
      })

      -- ── Go — gopls ─────────────────────────────────────────
      -- Install via Termux: pkg install golang
      -- gopls tersedia otomatis setelah install golang
      vim.lsp.config('gopls', {
        cmd       = { 'gopls' },
        filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
        root_markers = { 'go.mod', 'go.sum', 'go.work', '.git' },
        settings = {
          gopls = {
            analyses = {
              unusedparams  = true,
              shadow        = true,
              unusedwrite   = true,
              useany        = true,
            },
            staticcheck    = true,
            gofumpt        = false, -- Gunakan gofmt standar
            usePlaceholders = true, -- Isi placeholder di completion
            hints = {
              assignVariableTypes    = true,
              compositeLiteralFields = true,
              compositeLiteralTypes  = true,
              constantValues         = true,
              functionTypeParameters = true,
              parameterNames         = true,
              rangeVariableTypes     = true,
            },
          },
        },
      })

      -- ── Rust — rust-analyzer ──────────────────────────────
      -- Install via Termux: pkg install rust
      -- rust-analyzer tersedia di PATH setelah install
      vim.lsp.config('rust_analyzer', {
        cmd       = { 'rust-analyzer' },
        filetypes = { 'rust' },
        root_markers = { 'Cargo.toml', 'Cargo.lock', '.git' },
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              enable  = true,
              command = 'clippy',    -- Gunakan clippy untuk checking
              allFeatures = true,
            },
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
            },
            procMacro = { enable = true },
            inlayHints = {
              bindingModeHints         = { enable = false },
              chainingHints            = { enable = true },
              closingBraceHints        = { enable = true, minLines = 25 },
              closureReturnTypeHints   = { enable = 'never' },
              lifetimeElisionHints     = { enable = 'never' },
              parameterHints           = { enable = true },
              typeHints                = { enable = true, hideNamedConstructor = false },
            },
          },
        },
      })

      -- ── Lua — lua-language-server (opsional, untuk config Neovim) ─
      -- Install via Mason: :MasonInstall lua-language-server
      -- vim.lsp.config('lua_ls', {
      --   cmd       = { 'lua-language-server' },
      --   filetypes = { 'lua' },
      --   root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', '.git' },
      --   settings = {
      --     Lua = {
      --       runtime  = { version = 'LuaJIT' }, -- Neovim pakai LuaJIT
      --       workspace = {
      --         checkThirdParty = false,
      --         -- Kenali Neovim runtime
      --         library = vim.api.nvim_get_runtime_file('', true),
      --       },
      --       diagnostics = {
      --         globals  = { 'vim' }, -- Kenali global 'vim'
      --       },
      --       telemetry = { enable = false },
      --       hint      = { enable = true },
      --       format    = { enable = false }, -- Pakai stylua
      --     },
      --   },
      -- })

      -- ── Step 3: Setup mason-lspconfig ──────────────────────
      require('mason-lspconfig').setup({
        -- Server yang diinstall via mason otomatis
        ensure_installed = {
          'phpactor',       -- PHP
          'ts_ls',          -- TypeScript/JavaScript
          'svelte',         -- Svelte
          'tailwindcss',    -- TailwindCSS
          'vue_ls',         -- Vue
          -- 'lua_ls',         -- Lua (untuk konfigurasi Neovim)
          -- gopls & rust_analyzer diinstall via termux pkg
        },
        -- automatic_enable=true: panggil vim.lsp.enable() otomatis
        -- untuk server yang terinstall via mason
        automatic_enable = {
          -- Kecualikan server yang diinstall via termux (kita enable manual)
          exclude = { 'gopls', 'rust_analyzer' },
        },
      })

      -- ── Step 4: Enable server Termux secara manual ─────────
      -- Hanya enable jika binary tersedia di PATH
      if vim.fn.executable('gopls') == 1 then
        vim.lsp.enable('gopls')
      end
      if vim.fn.executable('rust-analyzer') == 1 then
        vim.lsp.enable('rust_analyzer')
      end

      -- ── Step 5: Keymap saat LSP attach (LspAttach autocmd) ──
      vim.api.nvim_create_autocmd('LspAttach', {
        group    = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
        desc     = 'Setup keymap saat LSP terhubung ke buffer',
        callback = function(ev)
          local bufnr  = ev.buf
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if not client then return end

          -- Helper keymap dengan buffer lokal
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or 'n', lhs, rhs, {
              buffer  = bufnr,
              noremap = true,
              silent  = true,
              desc    = 'LSP: ' .. desc,
            })
          end

          -- ── Navigasi ──────────────────────────────────────
          map('gd',         vim.lsp.buf.definition,      'Go to Definition')
          map('gD',         vim.lsp.buf.declaration,     'Go to Declaration')
          map('gr',         vim.lsp.buf.references,      'Referensi')
          map('gi',         vim.lsp.buf.implementation,  'Go to Implementation')
          map('gt',         vim.lsp.buf.type_definition, 'Go to Type Definition')

          -- ── Informasi ─────────────────────────────────────
          map('K',          vim.lsp.buf.hover,           'Dokumentasi Hover')
          map('<C-k>',      vim.lsp.buf.signature_help,  'Signature Help')

          -- ── Aksi Kode ─────────────────────────────────────
          map('<leader>ca', vim.lsp.buf.code_action,     'Code Action')
          map('<leader>ca', vim.lsp.buf.code_action,     'Code Action (Visual)', 'v')
          map('<leader>cr', vim.lsp.buf.rename,          'Rename Simbol')
          map('<leader>cf', function()
            require('conform').format({ bufnr = bufnr, async = true })
          end, 'Format Buffer')

          -- ── Diagnostic ────────────────────────────────────
          map('[d', vim.diagnostic.goto_prev,      'Diagnostic Sebelumnya')
          map(']d', vim.diagnostic.goto_next,      'Diagnostic Berikutnya')
          map('[e', function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, 'Error Sebelumnya')
          map(']e', function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, 'Error Berikutnya')

          -- ── Workspace ─────────────────────────────────────
          map('<leader>wa', vim.lsp.buf.add_workspace_folder,    'Tambah Workspace Folder')
          map('<leader>wr', vim.lsp.buf.remove_workspace_folder, 'Hapus Workspace Folder')
          map('<leader>wl', function()
            vim.notify(vim.inspect(vim.lsp.buf.list_workspace_folders()), vim.log.levels.INFO)
          end, 'Daftar Workspace Folder')

          -- ── Inlay Hints (Neovim 0.10+) ────────────────────
          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            -- Enable inlay hints secara default
            vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            map('<leader>uh', function()
              vim.lsp.inlay_hint.enable(
                not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
                { bufnr = bufnr }
              )
            end, 'Toggle Inlay Hints')
          end

          -- ── Document Highlight (kata yang sama di-highlight) ─
          if client.server_capabilities.documentHighlightProvider then
            local hl_group = vim.api.nvim_create_augroup('user_lsp_highlight_' .. bufnr, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group  = hl_group,
              buffer = bufnr,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group    = hl_group,
              buffer   = bufnr,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- ── Diagnostic Config Global ───────────────────────────
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          prefix  = '●',
          -- Hanya tampilkan error dan warning di virtual text (hemat ruang)
          severity = { min = vim.diagnostic.severity.WARN },
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = ' ',
            [vim.diagnostic.severity.WARN]  = ' ',
            [vim.diagnostic.severity.INFO]  = ' ',
            [vim.diagnostic.severity.HINT]  = '󰠠 ',
          },
        },
        underline     = true,
        update_in_insert = false,  -- Jangan update diagnostic saat insert mode
        severity_sort    = true,   -- Urutkan berdasarkan keparahan
        float = {
          focusable = false,
          style     = 'minimal',
          border    = 'rounded',
          source    = 'always',
          header    = '',
          prefix    = '',
        },
      })
    end,
  },

  -- ──────────────────────────────────────────────────────────
  -- 4. NVIM-CMP — Completion Engine
  -- ──────────────────────────────────────────────────────────
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',   -- Sumber: LSP
      'hrsh7th/cmp-buffer',     -- Sumber: kata di buffer
      'hrsh7th/cmp-path',       -- Sumber: path file sistem
      'saadparwaiz1/cmp_luasnip', -- Sumber: LuaSnip snippets
      {
        'L3MON4D3/LuaSnip',
        version      = 'v2.*',
        build        = 'make install_jsregexp', -- Opsional: regex JS
        dependencies = {
          -- Koleksi snippet untuk berbagai bahasa
          'rafamadriz/friendly-snippets',
        },
        config = function()
          -- Load snippet VS Code dari friendly-snippets
          require('luasnip.loaders.from_vscode').lazy_load()
          require('luasnip.loaders.from_vscode').lazy_load({
            paths = { vim.fn.stdpath('config') .. '/snippets' }, -- Snippet kustom Anda
          })

          -- Setup LuaSnip
          local ls = require('luasnip')
          ls.setup({
            history                  = true,
            delete_check_events      = 'TextChanged',
            -- Link snippet: if/elseif/else jadi satu
            link_children            = true,
            update_events            = 'TextChanged,TextChangedI',
            enable_autosnippets      = false,
            ext_opts                 = { [require('luasnip.util.types').choiceNode] = { active = { virt_text = { { '●', 'DiagnosticInfo' } } } } },
          })
        end,
      },
    },
    config = function()
      local cmp    = require('cmp')
      local luasnip = require('luasnip')

      -- Helper: apakah kursor setelah kata (bukan spasi)
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
      end

      cmp.setup({
        -- Snippet engine
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Tampilan popup
        window = {
          completion    = cmp.config.window.bordered({
            border     = 'rounded',
            winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel',
          }),
          documentation = cmp.config.window.bordered({
            border     = 'rounded',
            winhighlight = 'Normal:NormalFloat,FloatBorder:FloatBorder',
          }),
        },

        -- ── Keymap Completion ──────────────────────────────
        mapping = cmp.mapping.preset.insert({
          -- Ctrl+Space = Paksa buka completion
          ['<C-Space>'] = cmp.mapping.complete(),

          -- Ctrl+E = Tutup completion
          ['<C-e>']     = cmp.mapping.abort(),

          -- Ctrl+D/U = Scroll dokumentasi
          ['<C-d>']     = cmp.mapping.scroll_docs(4),
          ['<C-u>']     = cmp.mapping.scroll_docs(-4),

          -- Enter = Konfirmasi pilihan (hanya jika ada yang dipilih)
          ['<CR>']      = cmp.mapping.confirm({ select = false }),

          -- Tab = Pilih item berikutnya / expand snippet
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Shift+Tab = Pilih item sebelumnya / jump snippet mundur
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Arrow keys untuk navigasi
          ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
          ['<Up>']   = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { 'i' }),
        }),

        -- ── Sumber Completion (urutan = prioritas) ─────────
        sources = cmp.config.sources({
          { name = 'nvim_lsp', priority = 1000 }, -- LSP (paling prioritas)
          { name = 'luasnip',  priority = 750 },  -- Snippet
          { name = 'path',     priority = 500 },  -- Path file
        }, {
          -- Fallback: kata di buffer yang terbuka
          { name = 'buffer', priority = 250, keyword_length = 3,
            option = {
              get_bufnrs = function()
                -- Hanya dari buffer yang terlihat (hemat memori Termux)
                return vim.tbl_map(
                  vim.api.nvim_win_get_buf,
                  vim.api.nvim_list_wins()
                )
              end,
            },
          },
        }),

        -- ── Tampilan Item ─────────────────────────────────
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            -- Icon jenis item
            local kind_icons = {
              Text           = '󰉿', Method         = '󰆧', Function    = '󰊕',
              Constructor    = '', Field          = '󰜢', Variable    = '󰀫',
              Class          = '󰠱', Interface      = '', Module      = '',
              Property       = '󰜢', Unit           = '󰑭', Value       = '󰎠',
              Enum           = '', Keyword        = '󰌋', Snippet     = '',
              Color          = '󰏘', File           = '󰈙', Reference   = '󰈇',
              Folder         = '󰉋', EnumMember     = '', Constant    = '󰏿',
              Struct         = '󰙅', Event          = '', Operator    = '󰆕',
              TypeParameter  = '',
            }

            -- Label sumber completion
            local menu_labels = {
              nvim_lsp = '[LSP]',
              luasnip  = '[Snip]',
              buffer   = '[Buf]',
              path     = '[Path]',
            }

            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '', vim_item.kind)
            vim_item.menu = menu_labels[entry.source.name] or ('[' .. entry.source.name .. ']')

            -- Potong teks yang terlalu panjang (penting untuk Termux layar kecil)
            local MAX_ABBR = 40
            if #vim_item.abbr > MAX_ABBR then
              vim_item.abbr = vim_item.abbr:sub(1, MAX_ABBR) .. '…'
            end

            return vim_item
          end,
        },

        -- Jangan pilih item secara otomatis
        preselect    = cmp.PreselectMode.None,

        -- Jangan completion di komentar
        enabled = function()
          local ctx = require('cmp.config.context')
          if vim.api.nvim_get_mode().mode == 'c' then
            return true
          end
          return not ctx.in_treesitter_capture('comment')
            and not ctx.in_syntax_group('Comment')
        end,

        experimental = {
          ghost_text = { hl_group = 'Comment' }, -- Preview ghost text
        },
      })
    end,
  },
}
