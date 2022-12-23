local ok, indent_blankline = pcall(require, "indent_blankline")

if ok and indent_blankline then
	indent_blankline.setup({
		show_current_context = true,
	})
end
