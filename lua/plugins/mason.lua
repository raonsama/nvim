return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(p)
        return not vim.tbl_contains({
          "stylua",
          "lua_ls",
          "shellcheck",
          "shfmt",
        }, p)
      end, opts.ensure_installed)
    end,
  },
}
