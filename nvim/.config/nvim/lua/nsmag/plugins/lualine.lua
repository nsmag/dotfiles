local ok, lualine = pcall(require, "lualine")

if ok and lualine then
	lualine.setup({
		options = {
			theme = "tokyonight",
			component_separators = {
				left = "·",
				right = "·",
			},
			section_separators = {
				left = "",
				right = "",
			},
		},
	})
end
