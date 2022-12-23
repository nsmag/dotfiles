-- auto install packer if not installed
local ensure_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

	if fn.empty(fn.glob(install_path)) > 0 then
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])

		return true
	end

	return false
end

local packer_bootstrap = ensure_packer()

-- autocommand that reloads neovim and installs/updates/removes plugins
-- when file is saved
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

local ok, packer = pcall(require, "packer")

return ok
	and packer.startup(function(use)
		use("wbthomason/packer.nvim")

		-- ui
		use({
			"folke/tokyonight.nvim",
			config = function()
				vim.cmd("colorscheme tokyonight-night")
			end,
		})
		use({
			"nvim-tree/nvim-tree.lua",
			requires = {
				"nvim-tree/nvim-web-devicons",
			},
		})
		use({
			"nvim-lualine/lualine.nvim",
			requires = {
				"nvim-tree/nvim-web-devicons",
				opt = true,
			},
		})
		use("lukas-reineke/indent-blankline.nvim")

		-- lsp
		use({
			"nvim-treesitter/nvim-treesitter",
			run = function()
				local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
				ts_update()
			end,
		})

		use("williamboman/mason.nvim")
		use("williamboman/mason-lspconfig.nvim")
		use("neovim/nvim-lspconfig")
		use("hrsh7th/cmp-nvim-lsp")

		use("hrsh7th/nvim-cmp")
		use("hrsh7th/cmp-buffer")
		use("hrsh7th/cmp-path")
		use("windwp/nvim-autopairs")
		use("L3MON4D3/LuaSnip")
		use({
			"glepnir/lspsaga.nvim",
			branch = "main",
		})
		use("jose-elias-alvarez/typescript.nvim")
		use("onsails/lspkind.nvim")
		use("jose-elias-alvarez/null-ls.nvim")
		use("jayp0521/mason-null-ls.nvim")

		use({
			"akinsho/flutter-tools.nvim",
			requires = {
				"nvim-lua/plenary.nvim",
			},
		})

		-- telescope
		use({
			"nvim-telescope/telescope-fzf-native.nvim",
			run = "make",
		})
		use({
			"nvim-telescope/telescope.nvim",
			branch = "0.1.x",
			requires = {
				"nvim-lua/plenary.nvim",
			},
		})

		-- utils
		use("christoomey/vim-tmux-navigator")
		use("inkarkat/vim-ReplaceWithRegister")
		use({
			"numToStr/Comment.nvim",
			config = function()
				require("Comment").setup()
			end,
		})
		use("gpanders/editorconfig.nvim")

		if packer_bootstrap then
			require("packer").sync()
		end
	end)
