local setup, flutter_tools = pcall(require, "flutter-tools")
if not setup then
	return
end

flutter_tools.setup({
	lsp = {
		color = {
			enabled = true,
		},
	},
})
