local function split_length(line, width)
  local text = {}
  local next_line
  while true do
    if #line == 0 then
      return text
    end
    next_line, line = line:sub(1, width), line:sub(width)
    text[#text + 1] = next_line
  end
end

local function custom_wrap(lines, max_width)
  local wrapped_lines = {}
  for _, line in pairs(lines) do
    local new_lines = split_length(line, max_width)
    for _, nl in ipairs(new_lines) do
      nl = nl:gsub("^%s*", " "):gsub("%s*$", " ") 
      table.insert(wrapped_lines, nl)
    end
  end
  return wrapped_lines
end

return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3000,

      render = function(bufnr, notif, highlights, config)
        local api = vim.api
        local base = require("notify.render.base")

        local left_icon = notif.icon .. " "
        local max_message_width = config.max_width() 
        local right_title = notif.title[2]
        local left_title = notif.title[1]
        local title_accum = vim.str_utfindex(left_icon)
          + vim.str_utfindex(right_title)
          + vim.str_utfindex(left_title)

        local left_buffer = string.rep(" ", math.max(0, max_message_width - title_accum))

        local namespace = base.namespace()
        api.nvim_buf_set_lines(bufnr, 0, 1, false, { "", "" })
        api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
          virt_text = {
            { " " },
            { left_icon, highlights.icon },
            { left_title .. left_buffer, highlights.title },
          },
          virt_text_win_col = 0,
          priority = 10,
        })
        api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
          virt_text = { { " " }, { right_title, highlights.title }, { " " } },
          virt_text_pos = "right_align",
          priority = 10,
        })
        api.nvim_buf_set_extmark(bufnr, namespace, 1, 0, {
          virt_text = {
            {
              string.rep(
                "━",
                math.max(vim.str_utfindex(left_buffer) + title_accum + 2, config.minimum_width())
              ),
              highlights.border,
            },
          },
          virt_text_win_col = 0,
          priority = 10,
        })

        local wrapped_message = custom_wrap(notif.message, max_message_width)
        api.nvim_buf_set_lines(bufnr, 2, -1, false, wrapped_message)

        api.nvim_buf_set_extmark(bufnr, namespace, 2, 0, {
          hl_group = highlights.body,
          end_line = 1 + #wrapped_message,
          end_col = #wrapped_message[#wrapped_message],
          priority = 50, -- Allow treesitter to override
        })
      end,

      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,

      max_width = function()
        return math.floor(vim.o.columns * 0.35)
      end,

      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
    },
  },
}
