local ok, telescope = pcall(require, "telescope")

if ok and telescope then
	local actions = require("telescope.actions")

	telescope.setup({
		defaults = {
			file_ignore_patterns = {
				"^.git/",
			},
			mappings = {
				i = {
					["<C-k>"] = actions.move_selection_previous,
					["<C-j>"] = actions.move_selection_next,
				},
			},
		},
		pickers = {
			find_files = {
				hidden = true,
				no_ignore = true,
			},
		},
	})

	telescope.load_extension("fzf")
end
