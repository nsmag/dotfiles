local M = {}

--- Highlights for bufferline.nvim's `highlights` option.
--- Buffer names stay neutral; only diagnostic counts and the modified dot are coloured.
function M.get()
  local p = require("printemps.palette")
  local bg = p.surface
  local sel = require("printemps").config.transparent and "NONE" or p.base

  local hl = {
    fill = { bg = bg },
    background = { fg = p.muted, bg = bg },
    buffer_visible = { fg = p.subtle, bg = bg },
    buffer_selected = { fg = p.text, bg = sel, bold = true, italic = false },
    indicator_visible = { fg = bg, bg = bg },
    indicator_selected = { fg = p.forgetmenot, bg = sel },
    separator = { fg = bg, bg = bg },
    separator_visible = { fg = bg, bg = bg },
    separator_selected = { fg = bg, bg = sel },
    offset_separator = { fg = p.hl_high, bg = bg },
    trunc_marker = { fg = p.muted, bg = bg },
    tab = { fg = p.muted, bg = bg },
    tab_selected = { fg = p.text, bg = sel, bold = true },
    tab_separator = { fg = bg, bg = bg },
    tab_separator_selected = { fg = bg, bg = sel },
    tab_close = { fg = p.muted, bg = bg },
  }

  ---@param name string
  ---@param fg string[] inactive, visible, selected
  ---@param attrs? table extra attributes for the selected state
  local function states(name, fg, attrs)
    hl[name] = { fg = fg[1], bg = bg }
    hl[name .. "_visible"] = { fg = fg[2], bg = bg }
    hl[name .. "_selected"] = vim.tbl_extend("force", { fg = fg[3], bg = sel }, attrs or {})
  end

  local name_fg = { p.muted, p.subtle, p.text }
  local bold = { bold = true, italic = false }
  states("close_button", { p.muted, p.muted, p.subtle })
  states("numbers", name_fg)
  states("modified", { p.leaf, p.leaf, p.leaf })
  states("duplicate", { p.muted, p.muted, p.subtle }, { italic = true })
  states("pick", { p.geranium, p.geranium, p.geranium }, bold)
  states("diagnostic", name_fg, bold)
  for kind, color in pairs({ error = p.geranium, warning = p.ochre, info = p.forgetmenot, hint = p.sage }) do
    states(kind, name_fg, bold)
    states(kind .. "_diagnostic", { color, color, color }, bold)
  end

  return hl
end

return M
