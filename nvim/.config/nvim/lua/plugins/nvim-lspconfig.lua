return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      format = {
        timeout_ms = 2000,
      },
      servers = {
        cssls = {
          settings = {
            css = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
            less = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
            scss = {
              lint = {
                unknownAtRules = "ignore",
              },
            },
          },
        },
        lua_ls = {
          setup = {
            on_init = function(client)
              local path = client.workspace_folders[1].name
              if vim.loop.fs_stat(path .. "/.luarc.json") or vim.loop.fs_stat(path .. "/.luarc.jsonc") then
                return
              end

              client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                  version = "LuaJIT",
                },
                workspace = {
                  checkThirdParty = false,
                  library = {
                    vim.env.VIMRUNTIME,
                  },
                },
              })
            end,
          },
        },
        tailwindcss = {
          filetypes_exclude = { "markdown" },
          settings = {
            tailwindCSS = {
              experimental = {
                classRegex = {
                  {
                    "clsx\\(([^)]*)\\)",
                    "(?:'|\"|`)([^']*)(?:'|\"|`)",
                  },
                  {
                    "cva(?:\\<[^(]*)?\\(([^)]*)\\)",
                    "[\"'`]([^\"'`]*).*?[\"'`]",
                  },
                  { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                  { "toHaveClass\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
                },
              },
            },
          },
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          local tw = require("lspconfig.server_configurations.tailwindcss")
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, tw.default_config.filetypes)
        end,
      },
    },
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      -- prevent key conflict with nvim-cmp previous movement
      keys[#keys + 1] = { "<c-k>", false }
    end,
  },
}
