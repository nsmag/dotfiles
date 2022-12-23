local ok, nvimtree = pcall(require, "nvim-tree")

if ok and nvimtree then
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
end
