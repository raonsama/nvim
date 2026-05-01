-- Nonaktifkan provider yang tidak dipakai di Termux (hemat startup time)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_perl_provider    = 0

-- Nonaktifkan netrw (pakai nvim-tree sebagai pengganti)
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
