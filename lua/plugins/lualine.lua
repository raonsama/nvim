return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      local indent = {
        function()
          local space_pat = [[\v^ +]]
          local tab_pat = [[\v^\t+]]
          local space_indent = vim.fn.search(space_pat, 'nwc')
          local tab_indent = vim.fn.search(tab_pat, 'nwc')

          if space_indent > 0 and tab_indent == 0 then
            return "Spaces: " .. space_indent
          elseif tab_indent > 0 and space_indent == 0 then
            return "Tabs: " .. tab_indent
          elseif tab_indent == 0 and space_indent == 0 then
            return ""
          end

          local mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')

          if mixed_same_line > 0 then
            return 'Mixed: ' .. mixed_same_line
          end

          local space_indent_cnt = vim.fn.searchcount({pattern = space_pat, max_count = 1e3}).total
          local tab_indent_cnt = vim.fn.searchcount({pattern = tab_pat, max_count = 1e3}).total

          if space_indent_cnt > tab_indent_cnt then
            return 'Mixed: ' .. tab_indent
          else
            return 'Mixed: ' .. space_indent
          end
        end
      }

      table.insert(opts.sections.lualine_x, indent)
      table.insert(opts.sections.lualine_x, "encoding")
      table.insert(opts.sections.lualine_x, "fileformat")
    end
  }
}
