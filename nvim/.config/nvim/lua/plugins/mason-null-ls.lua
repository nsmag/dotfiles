return {
  {
    "williamboman/mason.nvim",
  },
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ensure_installed = {
        "astro-language-server",
        "css-lsp",
        "eslint_d",
        "gofumpt",
        "gopls",
        "gradle-language-server",
        "hadolint",
        "html-lsp",
        "jq",
        "json-lsp",
        "lua-language-server",
        "prettierd",
        "prisma-language-server",
        "rust-analyzer",
        "stylua",
        "tailwindcss-language-server",
        "taplo",
        "typescript-language-server",
        "xmlformatter",
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
    opts = function(_, opts)
      table.insert(opts.sources, require("typescript.extensions.null-ls.code-actions"))
    end,
  },
}
