vim.g.mapleader = " "

local keymap = vim.keymap

-- general
keymap.set("i", "jk", "<ESC>")
keymap.set("n", "<leader>nh", ":nohl<CR>")
keymap.set("n", "x", '"_x')
keymap.set("n", "<leader>tn", ":tabnew<CR>")
keymap.set("n", "<leader>tc", ":tabclose<CR>")
keymap.set("n", "<leader>t]", ":tabn<CR>")
keymap.set("n", "<leader>t[", ":tabp<CR>")
keymap.set("i", "<C-h>", "<left>")
keymap.set("i", "<C-j>", "<down>")
keymap.set("i", "<C-k>", "<up>")
keymap.set("i", "<C-l>", "<right>")

-- plugins
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

keymap.set("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
keymap.set("n", "<leader>fs", "<CMD>Telescope live_grep<CR>")
keymap.set("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
keymap.set("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")

keymap.set("n", "<leader>i", "<CMD>lua require('FTerm').toggle()<CR>")
keymap.set("t", "<ESC>", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>")
