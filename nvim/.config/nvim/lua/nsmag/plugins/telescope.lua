local t_setup, telescope = pcall(require, "telescope")
if not t_setup then
	return
end

local a_setup, actions = pcall(require, "telescope.actions")
if not a_setup then
	return
end

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
