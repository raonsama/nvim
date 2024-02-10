return {
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        border = "rounded",
      },
      ensure_installed = {
        "vue-language-server",
        "typescript-language-server",
        "gopls",
        "intelephense",
        "pyright",
        "ruff-lsp",
      },
    },
  },
}
