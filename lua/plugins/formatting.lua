-- ~/.config/nvim/lua/plugins/format.lua
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        php = { "laravel_pint" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
      },
      formatters = {
        laravel_pint = {
          command = "./vendor/bin/pint",
          args = { "$FILENAME" },
          stdin = false,
        },
        prettier = {
          condition = function(self, ctx)
            return vim.fs.find({
              ".prettierrc",
              ".prettierrc.json",
              ".prettierrc.js",
              ".prettierrc.yaml",
              ".prettierrc.yml",
              "package.json",
            }, { path = ctx.filename, upward = true })[1] ~= nil
          end,
        },
      },
    },
  },
}
