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

-- plugins
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

keymap.set("n", "<leader>ff", "<CMD>Telescope find_files<CR>")
keymap.set("n", "<leader>fs", "<CMD>Telescope live_grep<CR>")
keymap.set("n", "<leader>fc", "<CMD>Telescope grep_string<CR>")
keymap.set("n", "<leader>fb", "<CMD>Telescope buffers<CR>")
keymap.set("n", "<leader>fh", "<CMD>Telescope help_tags<CR>")

keymap.set("n", "<leader>i", "<CMD>lua require('FTerm').toggle()<CR>")
keymap.set("t", "<leader>i", "<C-\\><C-n><CMD>lua require('FTerm').toggle()<CR>")
