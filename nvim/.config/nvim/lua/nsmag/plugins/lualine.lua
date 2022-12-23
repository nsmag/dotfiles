local lualine_setup, lualine = pcall(require, "lualine")
if not lualine_setup then
	return
end

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
