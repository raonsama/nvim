-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      intelephense = {
        init_options = {
          globalStoragePath = vim.fn.stdpath("data") .. "/intelephense",
        },
        settings = {
          intelephense = {
            -- Update path to desired directory
            files = {
              exclude = {
                "**/.git/**",
                "**/node_modules/**",
                "**/vendor/**/test*/**",
                "**/vendor/**/Tests/**",
                "**/vendor/**/spec/**",
                "**/storage/**",
                "**/public/build/**",
                "**/public/hot/**",
                "**/*.min.js",
                "**/*.min.css",
              },
            },
            telemetry = { enabled = false },
          },
        },
      },
      lua_ls = false,
      stylua = { mason = false },
    },
  },
  {
    'ccaglak/namespace.nvim',
    event = 'VeryLazy',
    keys = {
        { "<leader>pa", "<cmd>Php classes<cr>", desc="Import PHP Classes"},
        { "<leader>pc", "<cmd>Php class<cr>", desc="Import PHP Class"},
        { "<leader>pn", "<cmd>Php namespace<cr>", desc="PHP Namespace"},
        { "<leader>ps", "<cmd>Php sort<cr>", desc="Sort PHP Classes"},
    },
    -- dependencies = {
    --     "ccaglak/phptools.nvim", -- optional
    --     "ccaglak/larago.nvim", -- optional
    -- }
    config = function()
    require('namespace').setup({
      ui = true, -- default: true -- false only if you want to use your own ui
      cacheOnload = false, -- default: false -- cache composer.json on load
      dumpOnload = false, -- default: false -- dump composer.json on load
      sort = {
        on_save = false, -- default: false -- sorts on every search
        sort_type = 'length_desc', -- default: natural -- seam like what pint is sorting
        --  ascending -- descending -- length_asc
        -- length_desc -- natural -- case_insensitive
      },
    })
    end,
  },
}
