return {
  {
    "nvim-lualine/lualine.nvim",
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

          if mixed_same_line > 0 or tab_indent > 0 and space_indent > 0 then
            return "Mixed"
          end

          return ""
        end
      }

      local check_lsp = {
        function()
          local msg = 'No Active'
          local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            local get_client_name = client.name
            local char_replace = get_client_name:gsub("_", " ")
            local client_name = char_replace:gsub("%f[%a].", string.upper)
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client_name
            end
          end
          return msg
        end,
        icon = ' LSP:',
      }

      table.insert(opts.sections.lualine_x, indent)
      table.insert(opts.sections.lualine_x, { "encoding", fmt = string.upper })
      table.insert(opts.sections.lualine_x, { "fileformat", icons_enabled = false, fmt = string.upper })

      opts.sections.lualine_z = { check_lsp, }
    end
  }
}
