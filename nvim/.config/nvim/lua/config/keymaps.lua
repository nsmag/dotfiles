local map = vim.keymap.set

-- "jk" to escape from insert mode
map("i", "jk", "<esc>")

-- Move in insert mode
map("i", "<c-h>", "<left>")
map("i", "<c-j>", "<down>")
map("i", "<c-k>", "<up>")
map("i", "<c-l>", "<right>")

-- nvim-tmux-navigation
map("n", "<c-h>", "<cmd>NvimTmuxNavigateLeft<cr>")
map("n", "<c-j>", "<cmd>NvimTmuxNavigateDown<cr>")
map("n", "<c-k>", "<cmd>NvimTmuxNavigateUp<cr>")
map("n", "<c-l>", "<cmd>NvimTmuxNavigateRight<cr>")
