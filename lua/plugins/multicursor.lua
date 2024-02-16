return { -- Multi Cursor
  "mg979/vim-visual-multi",
  event = "LazyFile",
  init = function()
    vim.g.VM_theme = "purplegray"
    vim.g.VM_mouse_mappings = 1
    vim.g.VM_set_statusline = 0
    vim.g.VM_maps = {
      ["Find Under"] = "<C-d>",
      ["Find Subword Under"] = "<C-d>",
      ["Select Cursor Down"] = "<M-C-Down>",
      ["Select Cursor Up"] = "<M-C-Up>",
    }
  end,
}
