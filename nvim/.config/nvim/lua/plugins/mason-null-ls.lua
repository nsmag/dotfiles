return {
  {
    "williamboman/mason.nvim",
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "dockerfile-language-server",
        "eslint_d",
        "gofumpt",
        "gopls",
        "hadolint",
        "html-lsp",
        "jq",
        "json-lsp",
        "kotlin-language-server",
        "lua-language-server",
        "prettier",
        "rust-analyzer",
        "stylua",
        "tailwindcss-language-server",
        "taplo",
        "typescript-language-server",
        "xmlformatter",
        "yaml-language-server",
        "yamlfmt",
      },
      automatic_installation = true,
      automatic_setup = true,
    },
    config = function(plugin, opts)
      require("mason-null-ls").setup(opts)
      require("mason-null-ls").setup_handlers()
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    -- opts = function()
    --   local nls = require("null-ls")
    --   return {
    --     sources = {},
    --   }
    -- end,
  },
}
