-- ~/.config/nvim/lua/plugins/disabled.lua
-- Opt-out plugin berat (UI/Treesitter/LSP)
return {
  { "folke/noice.nvim", enabled = false }, -- Berat di UI/Animation
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvim-treesitter/nvim-treesitter-context", enabled = false },
  { "folke/flash.nvim", enabled = false },
  { "folke/snacks.nvim", opts = { dashboard = { enabled = false } } },
}
