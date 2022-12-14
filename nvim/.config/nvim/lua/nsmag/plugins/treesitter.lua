local ok, treesitter = pcall(require, "nvim-treesitter.configs")

if ok and treesitter then
	treesitter.setup({
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
		ensure_installed = {
			"bash",
			"css",
			"dart",
			"dockerfile",
			"gitignore",
			"go",
			"graphql",
			"html",
			"javascript",
			"json",
			"lua",
			"rust",
			"toml",
			"typescript",
			"vim",
			"yaml",
		},
		auto_install = true,
	})
end
