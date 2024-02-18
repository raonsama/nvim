return { 
  {
    "mg979/vim-visual-multi",
    event = "LazyFile",
    init = function()
      vim.g.VM_theme = "purplegray"
      vim.g.VM_mouse_mappings = 0
      vim.g.VM_set_statusline = 0
      vim.g.VM_maps = {
        ["Move Left"] = "",
        ["Move Right"] = "",
        ["Select h"] = "",
        ["Select l"] = "",
      }
    end
  },
}
