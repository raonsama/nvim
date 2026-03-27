-- ============================================================
-- NEOVIM CONFIG — lua/plugins/init.lua
-- Semua plugin non-kritikal pakai lazy loading
-- ============================================================
return {

  -- --- COLORSCHEME: load pertama, tidak boleh lazy ---
  {
    "folke/tokyonight.nvim",
    lazy     = false,
    priority = 1000,
    config   = function()
      require("tokyonight").setup({ style = "night", transparent = true })
      vim.cmd([[colorscheme tokyonight-night]])
    end,
  },

  -- --- GITSIGNS: lazy, load hanya saat masuk git repo ---
  {
    "lewis6991/gitsigns.nvim",
    event  = { "BufReadPre", "BufNewFile" },
    config = function()
      require('gitsigns').setup({
        signcolumn        = true,
        current_line_blame = false,
        -- Debounce: tunggu 300ms setelah ketikan terakhir sebelum re-run git diff
        -- Default 100ms terlalu agresif untuk Termux
        update_debounce   = 300,
        watch_gitdir      = {
          follow_files = true,
          interval     = 2000,  -- cek perubahan git dir tiap 2 detik (default 1000)
        },
      })
    end,
  },

   -- --- TREESITTER: lazy via event ---
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "php", "typescript", "tsx", "javascript",
          "html", "css", "lua", "json", "bash", "yaml", "xml",
        },
      })

      -- Tambah filetype lain sesuai kebutuhan
      local ts_filetypes = {
        "php", "typescript", "tsx", "javascript",
        "html", "css", "lua", "json", "bash", "yaml", "xml",
      }

      vim.api.nvim_create_autocmd("FileType", {
        group    = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
        pattern  = ts_filetypes,
        callback = function(ev)
          -- Jangan jalankan di buffer special (NvimTree, terminal, dll)
          if vim.bo[ev.buf].buftype ~= "" then return end
          pcall(vim.treesitter.start, ev.buf)
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        group   = vim.api.nvim_create_augroup("ts_indent", { clear = true }),
        pattern = { "php", "typescript", "tsx", "javascript", "html", "css", "lua" },
        callback = function(ev)
          if vim.bo[ev.buf].buftype ~= "" then return end
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- --- LSP + MASON: lazy via event ---
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },  -- LSP aktif hanya saat buka file
    dependencies = {
      { "mason-org/mason.nvim" },
      { "mason-org/mason-lspconfig.nvim" },
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      -- "roobert/tailwindcss-colorizer-cmp.nvim",
    },
    config = function()
      require("mason").setup({ ui = { border = "rounded" } })
      vim.lsp.config('intelephense', {
         settings = {
           intelephense = {
             files = {
               exclude = {
                 "**/.git/**",
                 "**/node_modules/**",
                 "**/storage/**",
                 "**/public/build/**",
                 "**/public/hot/**",
                 "**/*.min.js",
                 "**/*.min.css",
               },
               -- Naikkan maxSize agar file besar tidak di-skip tapi juga tidak freeze
               maxSize = 1000000,
             },
             -- Matikan fitur yang tidak dibutuhkan di Termux/ARM
             telemetry = { enabled = false },
             completion = {
               fullyQualifyGlobalConstantsAndFunctions = false,
             },
           },
         },
      })

      -- Capabilities global (wildcard '*' berlaku ke semua LSP)
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      vim.lsp.config('*', { capabilities = capabilities })

      require("mason-lspconfig").setup({
        ensure_installed = { "intelephense", "ts_ls", "tailwindcss" },
        -- automatic_enable = true  ← DEFAULT, tidak perlu ditulis
      })

      -- require("tailwindcss-colorizer-cmp").setup({
      --   color_square_width = 2,
      -- })

      -- --- AUTOCOMPLETE (CMP) dengan performa tuning ---
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) require('luasnip').lsp_expand(args.body) end,
        },
        -- formatting = {
        --   format = require("tailwindcss-colorizer-cmp").formatter
        -- },
        -- Performance: batasi jumlah item yang diproses CMP
        performance = {
          debounce          = 60,    -- ms tunggu setelah ketikan sebelum query (default 60)
          throttle          = 30,    -- ms minimum antar render (default 30)
          fetching_timeout  = 500,   -- ms timeout per source (default 500)
          max_view_entries  = 10,    -- tampilkan max 10 item (default 200!)
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>']      = cmp.mapping.confirm({ select = true }),
          ['<Tab>']     = cmp.mapping.select_next_item(),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp', max_item_count = 15 },  -- batasi item per source
          { name = 'luasnip',  max_item_count = 5 },
        }, {
          { name = 'buffer',   max_item_count = 5, keyword_length = 3 },
          { name = 'path',     max_item_count = 5 },
        }),
      })
    end,
  },

  -- --- NVIM-TREE: lazy, load via keymap atau command ---
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd          = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
    keys         = { { "<C-b>", "<cmd>NvimTreeToggle<CR>" } },
    config       = function()
      require("nvim-tree").setup({
        hijack_netrw = false,
        sync_root_with_cwd = true,
        view = { adaptive_size = false, width = 30 },
        renderer = { group_empty = true },
        filters = { dotfiles = true },
        update_focused_file = { enable = true, update_root = true },
      })
    end,
  },

  -- --- TELESCOPE: lazy, load via keymap ---
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
        -- Jangan index folder berat
        file_ignore_patterns = {
          "vendor/.*", "node_modules/.*", "%.git/.*",
          "storage/.*", "public/build/.*", "%.min%.js",
          "%.min%.css", "%.lock",
        },
        -- Batasi hasil agar tidak overwhelm ARM CPU
        layout_strategy   = "vertical",
        layout_config     = { height = 0.8, width = 0.7 },
        -- Kurangi preview overhead
        dynamic_preview_title = true,
      },
      pickers = {
        find_files = {
          -- fd jauh lebih cepat dari find di Termux
          find_command = { "fd", "--type", "f", "--hidden", "--strip-cwd-prefix" },
        },
        live_grep = {
          additional_args = { "--max-count=1" },  -- 1 match per file cukup untuk navigasi
        },
      },
    })
  end,
  },

  -- --- SPECTRE: lazy, load via keymap ---
  {
    "nvim-pack/nvim-spectre",
    keys   = { { "<leader>h", function() require('spectre').toggle() end } },
    config = function() require('spectre').setup({ open_cmd = 'vnew' }) end,
  },

  -- --- COMMENT: lazy, load hanya saat ada file ---
  {
    "numToStr/Comment.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function() require('Comment').setup() end,
  },

  -- --- AUTOPAIRS: sudah lazy via event InsertEnter ---
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function() require("nvim-autopairs").setup {} end,
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- Opsional: Menambahkan dependensi agar icon muncul (jika pakai nvim-web-devicons)
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- Membuat shortcut keyboard
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
}
