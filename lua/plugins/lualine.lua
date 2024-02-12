return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local indent = {
        function()
          local style = vim.bo.expandtab and "Spaces" or "Tab Size"
          local size = vim.bo.expandtab and vim.bo.tabstop or vim.bo.shiftwidth
          return style .. ": " .. size
        end
      }
      table.insert(opts.sections.lualine_x, indent)
      table.insert(opts.sections.lualine_x, "encoding")
      table.insert(opts.sections.lualine_x, "fileformat")
    end
  }
}
