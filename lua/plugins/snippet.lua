return {
  {
    "L3MON4D3/LuaSnip",
    event = "LazyFile",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
    end,
  },
}
