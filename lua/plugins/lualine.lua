return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local indent = {
        function()
          local space_indent = vim.fn.search([[\v^ +]], "nwc")
          local tab_indent = vim.fn.search([[\v^\t+]], "nwc")

          if space_indent > 0 and tab_indent == 0 then
            return "Spaces"
          elseif tab_indent > 0 and space_indent == 0 then
            return "Tabs"
          elseif tab_indent == 0 and space_indent == 0 then
            return ""
          end

          local mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], "nwc")

          if mixed_same_line > 0 then
            return "Mixed"
          end
        end
      }

      table.insert(opts.sections.lualine_x, indent)
      table.insert(opts.sections.lualine_x, "encoding")
      table.insert(opts.sections.lualine_x, "fileformat")
    end
  }
}
