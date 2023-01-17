local saga_ok, saga = pcall(require, "lspsaga")

if saga_ok and saga then
	saga.init_lsp_saga({
		move_in_saga = {
			next = "<C-j>",
			prev = "<C-k>",
		},
		finder_action_keys = {
			open = "<CR>",
		},
		definition_action_keys = {
			edit = "<CR>",
		},
		code_action_lightbulb = {
			virtual_text = false,
		},
	})
end

local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
local cmp_nvim_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local typescript_ok, typescript = pcall(require, "typescript")
local flutter_tools_ok, flutter_tools = pcall(require, "flutter-tools")

if not (lspconfig_ok and cmp_nvim_lsp_ok and typescript_ok and flutter_tools_ok) then
	return
end

local keymap = vim.keymap
local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true, buffer = bufnr }

	keymap.set("n", "gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
	keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- go to declaration
	keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
	keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
	keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
	keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
	keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
	keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
	keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side

	if client.name == "tsserver" then
		keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
		keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports
		keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables
	end
end
local capabilities = cmp_nvim_lsp.default_capabilities()

-- servers
local lsp_default_config = {
	on_attach = on_attach,
	capabilities = capabilities,
}

local servers = {
	cssls = {},
	dockerls = {},
	gopls = {
		cmd = { "gopls", "--remote=auto" },
		init_options = {
			usePlaceholders = true,
			completeUnimported = true,
		},
		gofumpt = true,
	},
	html = {},
	jsonls = {},
	sumneko_lua = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
	},
	rust_analyzer = {},
	taplo = {},
	tailwindcss = {},
	yamlls = {},
}

for server, config in pairs(servers) do
	lspconfig[server].setup(vim.tbl_deep_extend("force", lsp_default_config, config))
end

typescript.setup({
	server = {
		on_attach = on_attach,
		capabilities = capabilities,
	},
})

flutter_tools.setup({
	lsp = {
		color = {
			enabled = true,
		},
		on_attach = on_attach,
		capabilities = capabilities,
	},
})

local null_ls_setup, null_ls = pcall(require, "null-ls")
if not null_ls_setup then
	return
end

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
	-- souces from mason.lua
	sources = {
		formatting.dart_format,
		diagnostics.hadolint,
		formatting.gofumpt,
		formatting.jq,
		formatting.prettier,
		diagnostics.eslint_d.with({
			condition = function(utils)
				return utils.root_has_file(".eslintrc.js")
			end,
		}),
		formatting.stylua,
		formatting.taplo,
		formatting.yamlfmt,
	},
	-- configure format on save
	on_attach = function(current_client, bufnr)
		if current_client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							--  only use null-ls for formatting instead of lsp server
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})
