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
        "gradle-language-server",
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
    config = function(_, opts)
      require("mason-null-ls").setup(opts)
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
}
