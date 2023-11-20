return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      { "windwp/nvim-ts-autotag" },
    },
    opts = {
      ensure_installed = {
        "astro",
        "bash",
        "dart",
        "html",
        "javascript",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "prisma",
        "python",
        "regex",
        "swift",
        "toml",
        "vim",
        "yaml",
      },
      autotag = {
        enable = true,
        enable_rename = true,
        enable_close = true,
        enable_close_on_slash = false,
      },
    },
    init = function()
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
