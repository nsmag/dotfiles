local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
	return
end

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

nvimtree.setup({
	renderer = {
		indent_markers = {
			enable = true,
		},
		icons = {
			git_placement = "after",
			glyphs = {
				git = {
					unstaged = "!",
					staged = "+",
					unmerged = "=",
					renamed = "»",
					untracked = "?",
					deleted = "✗",
				},
			},
		},
	},
})
