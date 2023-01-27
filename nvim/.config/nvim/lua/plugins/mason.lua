return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "dockerfile-language-server",
        "gopls",
        "html-lsp",
        "rust-analyzer",
        "taplo",
        "tailwindcss-language-server",
        "yaml-language-server",
      },
    },
  },
}
