local ok, mason = pcall(require, "mason")

if ok and mason then
	mason.setup()
end

local ok2, mason_lspconfig = pcall(require, "mason-lspconfig")

if ok2 and mason_lspconfig then
	mason_lspconfig.setup({
		ensure_installed = {
			"cssls", -- css
			"dockerls", -- docker
			"gopls", -- go
			"html", -- html
			"tsserver", -- js, ts
			"jsonls",
			"sumneko_lua", -- lua
			"rust_analyzer", -- rust
			"taplo", -- toml
			"tailwindcss", -- tailwindcss
			"yamlls", -- yaml
		},
		automatic_installation = true,
	})
end

local ok3, mason_null_ls = pcall(require, "mason-null-ls")

if ok3 and mason_null_ls then
	mason_null_ls.setup({
		ensure_installed = {
			"hadolint", -- docker
			"gofumpt", -- go
			"prettier", -- js, ts, css, html
			"eslint_d", -- js, ts
			"jq", -- json
			"stylua", -- lua
			"taplo", -- toml
			"yamlfmt", -- yaml
		},
		automatic_installation = true,
	})
end
