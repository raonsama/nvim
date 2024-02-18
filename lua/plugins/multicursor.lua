return { 
  "mg979/vim-visual-multi",
  event = "LazyFile",
  init = function()
    vim.g.VM_theme = "purplegray"
    vim.g.VM_mouse_mappings = 1
    vim.g.VM_set_statusline = 0
  end,
}
