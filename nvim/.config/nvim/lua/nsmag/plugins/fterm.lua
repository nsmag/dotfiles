local ok, fterm = pcall(require, "FTerm")

if ok and fterm then
	fterm.setup({
		border = "rounded",
		dimensions = {
			width = 0.9,
			height = 0.9,
		},
	})
end
