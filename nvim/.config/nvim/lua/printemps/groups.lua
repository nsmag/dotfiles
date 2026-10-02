local M = {}

local function to_linear(c)
  return c <= 0.04045 and c / 12.92 or ((c + 0.055) / 1.055) ^ 2.4
end

local function to_srgb(c)
  c = c <= 0.0031308 and 12.92 * c or 1.055 * c ^ (1 / 2.4) - 0.055
  return math.floor(math.min(1, math.max(0, c)) * 255 + 0.5)
end

local function to_oklab(hex)
  local r, g, b =
    to_linear(tonumber(hex:sub(2, 3), 16) / 255),
    to_linear(tonumber(hex:sub(4, 5), 16) / 255),
    to_linear(tonumber(hex:sub(6, 7), 16) / 255)
  local l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ^ (1 / 3)
  local m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ^ (1 / 3)
  local s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ^ (1 / 3)
  return {
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  }
end

local function from_oklab(lab)
  local l = (lab[1] + 0.3963377774 * lab[2] + 0.2158037573 * lab[3]) ^ 3
  local m = (lab[1] - 0.1055613458 * lab[2] - 0.0638541728 * lab[3]) ^ 3
  local s = (lab[1] - 0.0894841775 * lab[2] - 1.2914855480 * lab[3]) ^ 3
  return string.format(
    "#%02x%02x%02x",
    to_srgb(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
    to_srgb(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
    to_srgb(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)
  )
end

--- Same as CSS `color-mix(in oklab, fg amount, bg)`, which the preview uses for tints.
---@param fg string
---@param bg string
---@param amount number 0..1 share of `fg`
function M.mix(fg, bg, amount)
  local a, b = to_oklab(fg), to_oklab(bg)
  return from_oklab({
    a[1] * amount + b[1] * (1 - amount),
    a[2] * amount + b[2] * (1 - amount),
    a[3] * amount + b[3] * (1 - amount),
  })
end

---@param p printemps.Palette
---@param opts printemps.Config
---@return table<string, vim.api.keyset.highlight>
function M.get(p, opts)
  local bg = opts.transparent and "NONE" or p.base
  local function tint(color, amount)
    return M.mix(color, p.base, amount)
  end

  local diag = { Error = p.geranium, Warn = p.ochre, Info = p.forgetmenot, Hint = p.sage, Ok = p.leaf }
  local heading = { p.tulip, p.wallflower, p.ochre, p.leaf, p.forgetmenot, p.lilac }

  -- stylua: ignore
  local hl = {
    -- editor ---------------------------------------------------------------
    Normal = { fg = p.text, bg = bg },
    NormalNC = { fg = p.text, bg = bg },
    NormalFloat = { fg = p.text, bg = p.surface },
    FloatBorder = { fg = p.hl_high, bg = p.surface },
    FloatTitle = { fg = p.forgetmenot, bg = p.surface, bold = true },
    FloatFooter = { fg = p.muted, bg = p.surface },
    Bold = { fg = p.text, bold = true },
    Italic = { italic = true },
    ColorColumn = { bg = p.surface },
    Conceal = { fg = p.subtle },
    Cursor = { fg = p.base, bg = p.text },
    lCursor = { link = "Cursor" },
    CursorIM = { link = "Cursor" },
    TermCursor = { link = "Cursor" },
    CursorColumn = { bg = p.surface },
    CursorLine = { bg = p.surface },
    CursorLineNr = { fg = p.ochre, bold = true },
    LineNr = { fg = p.muted },
    SignColumn = { fg = p.muted, bg = bg },
    FoldColumn = { fg = p.muted, bg = bg },
    Folded = { fg = p.subtle, bg = p.surface },
    EndOfBuffer = { fg = p.overlay, bg = bg },
    NonText = { fg = p.muted },
    Whitespace = { fg = p.hl_med },
    SpecialKey = { fg = p.muted },
    Directory = { fg = p.forgetmenot },
    Title = { fg = p.forgetmenot, bold = true },
    Visual = { bg = p.hl_med },
    VisualNOS = { link = "Visual" },
    Search = { fg = p.text, bg = p.hl_high },
    CurSearch = { fg = p.base, bg = p.ochre, bold = true },
    IncSearch = { link = "CurSearch" },
    Substitute = { fg = p.base, bg = p.geranium },
    MatchParen = { fg = p.pollen, bg = p.hl_med, bold = true },
    QuickFixLine = { bg = p.hl_med },
    WinSeparator = { fg = p.hl_high },
    VertSplit = { link = "WinSeparator" },
    StatusLine = { fg = p.subtle, bg = p.surface },
    StatusLineNC = { fg = p.muted, bg = p.surface },
    StatusLineTerm = { link = "StatusLine" },
    StatusLineTermNC = { link = "StatusLineNC" },
    TabLine = { fg = p.muted, bg = p.surface },
    TabLineFill = { bg = bg }, -- tabline groups without a bg inherit this one
    TabLineSel = { fg = p.text, bg = bg, bold = true },
    WinBar = { fg = p.subtle, bg = bg },
    WinBarNC = { fg = p.muted, bg = bg },
    Pmenu = { fg = p.subtle, bg = p.surface },
    PmenuSel = { fg = p.text, bg = p.hl_med },
    PmenuKind = { fg = p.lilac, bg = p.surface },
    PmenuKindSel = { fg = p.lilac, bg = p.hl_med },
    PmenuExtra = { fg = p.muted, bg = p.surface },
    PmenuExtraSel = { fg = p.subtle, bg = p.hl_med },
    PmenuMatch = { fg = p.ochre, bold = true },
    PmenuMatchSel = { fg = p.ochre, bold = true },
    PmenuSbar = { bg = p.surface },
    PmenuThumb = { bg = p.hl_high },
    WildMenu = { link = "PmenuSel" },
    ModeMsg = { fg = p.subtle, bold = true },
    MsgArea = { fg = p.text },
    MoreMsg = { fg = p.leaf },
    Question = { fg = p.forgetmenot },
    ErrorMsg = { fg = p.geranium },
    WarningMsg = { fg = p.ochre },
    SpellBad = { sp = p.geranium, undercurl = true },
    SpellCap = { sp = p.ochre, undercurl = true },
    SpellLocal = { sp = p.sage, undercurl = true },
    SpellRare = { sp = p.lilac, undercurl = true },

    -- diff -----------------------------------------------------------------
    DiffAdd = { bg = tint(p.leaf, 0.15) },
    DiffDelete = { bg = tint(p.geranium, 0.14) },
    DiffChange = { bg = tint(p.ochre, 0.10) },
    DiffText = { bg = tint(p.ochre, 0.28) },
    Added = { fg = p.leaf },
    Changed = { fg = p.ochre },
    Removed = { fg = p.geranium },
    diffAdded = { link = "Added" },
    diffChanged = { link = "Changed" },
    diffRemoved = { link = "Removed" },
    diffFile = { fg = p.forgetmenot },
    diffLine = { fg = p.lilac },

    -- syntax ---------------------------------------------------------------
    Comment = { fg = p.muted, italic = true },
    Constant = { fg = p.wallflower },
    String = { fg = p.leaf },
    Character = { fg = p.leaf },
    Number = { fg = p.wallflower },
    Boolean = { fg = p.wallflower },
    Float = { fg = p.wallflower },
    Identifier = { fg = p.text },
    Function = { fg = p.forgetmenot },
    Statement = { fg = p.lilac },
    Conditional = { fg = p.lilac },
    Repeat = { fg = p.lilac },
    Label = { fg = p.sage },
    Operator = { fg = p.subtle },
    Keyword = { fg = p.lilac },
    Exception = { fg = p.lilac },
    PreProc = { fg = p.lilac },
    Include = { fg = p.lilac },
    Define = { fg = p.lilac },
    Macro = { fg = p.lilac },
    PreCondit = { fg = p.lilac },
    Type = { fg = p.ochre },
    StorageClass = { fg = p.lilac },
    Structure = { fg = p.ochre },
    Typedef = { fg = p.ochre },
    Special = { fg = p.sage },
    SpecialChar = { fg = p.sage },
    Tag = { fg = p.ochre },
    Delimiter = { fg = p.subtle },
    SpecialComment = { fg = p.subtle, italic = true },
    Debug = { fg = p.tulip },
    Underlined = { fg = p.forgetmenot, underline = true },
    Ignore = { fg = p.muted },
    Error = { fg = p.geranium },
    Todo = { fg = p.base, bg = p.ochre, bold = true },

    -- treesitter -----------------------------------------------------------
    ["@variable"] = { fg = p.text },
    ["@variable.builtin"] = { fg = p.tulip },
    ["@variable.parameter"] = { fg = p.hydrangea, italic = true },
    ["@variable.parameter.builtin"] = { fg = p.tulip, italic = true },
    ["@variable.member"] = { fg = p.sage },
    ["@constant"] = { link = "Constant" },
    ["@constant.builtin"] = { link = "Constant" },
    ["@constant.macro"] = { link = "Constant" },
    ["@module"] = { fg = p.text },
    ["@module.builtin"] = { fg = p.tulip },
    ["@namespace.builtin"] = { link = "@module.builtin" }, -- `vim` in neovim's bundled lua query
    ["@label"] = { link = "Label" },
    ["@string"] = { link = "String" },
    ["@string.documentation"] = { fg = p.leaf, italic = true },
    ["@string.regexp"] = { fg = p.sage },
    ["@string.escape"] = { fg = p.sage },
    ["@string.special"] = { fg = p.sage },
    ["@string.special.symbol"] = { fg = p.wallflower },
    ["@string.special.path"] = { fg = p.leaf, underline = true },
    ["@string.special.url"] = { fg = p.sky, underline = true },
    ["@character"] = { link = "Character" },
    ["@character.special"] = { link = "SpecialChar" },
    ["@boolean"] = { link = "Boolean" },
    ["@number"] = { link = "Number" },
    ["@number.float"] = { link = "Float" },
    ["@type"] = { link = "Type" },
    ["@type.builtin"] = { link = "Type" },
    ["@type.definition"] = { link = "Type" },
    ["@attribute"] = { fg = p.lilac },
    ["@attribute.builtin"] = { fg = p.lilac },
    ["@property"] = { fg = p.sage },
    ["@function"] = { link = "Function" },
    ["@function.builtin"] = { fg = p.tulip },
    ["@function.call"] = { link = "Function" },
    ["@function.macro"] = { fg = p.lilac },
    ["@function.method"] = { link = "Function" },
    ["@function.method.call"] = { link = "Function" },
    ["@constructor"] = { fg = p.ochre },
    ["@constructor.lua"] = { fg = p.subtle }, -- table braces
    ["@operator"] = { link = "Operator" },
    ["@keyword"] = { link = "Keyword" },
    ["@keyword.operator"] = { link = "Keyword" },
    ["@keyword.import"] = { link = "Include" },
    ["@keyword.directive"] = { link = "PreProc" },
    ["@punctuation.delimiter"] = { fg = p.subtle },
    ["@punctuation.bracket"] = { fg = p.subtle },
    ["@punctuation.special"] = { fg = p.subtle },
    ["@comment"] = { link = "Comment" },
    ["@comment.documentation"] = { link = "Comment" },
    ["@comment.error"] = { fg = p.base, bg = p.geranium, bold = true },
    ["@comment.warning"] = { fg = p.base, bg = p.ochre, bold = true },
    ["@comment.todo"] = { fg = p.base, bg = p.forgetmenot, bold = true },
    ["@comment.note"] = { fg = p.base, bg = p.sage, bold = true },
    ["@tag"] = { fg = p.ochre },
    ["@tag.builtin"] = { fg = p.tulip },
    ["@tag.attribute"] = { fg = p.sage },
    ["@tag.delimiter"] = { fg = p.subtle },
    ["@diff.plus"] = { link = "Added" },
    ["@diff.minus"] = { link = "Removed" },
    ["@diff.delta"] = { link = "Changed" },

    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"] = { underline = true },
    ["@markup.heading"] = { fg = p.forgetmenot, bold = true },
    ["@markup.quote"] = { fg = p.subtle, italic = true },
    ["@markup.math"] = { fg = p.sage },
    ["@markup.link"] = { fg = p.forgetmenot },
    ["@markup.link.label"] = { fg = p.forgetmenot },
    ["@markup.link.url"] = { fg = p.sky, underline = true },
    ["@markup.raw"] = { fg = p.leaf },
    ["@markup.list"] = { fg = p.lilac },
    ["@markup.list.checked"] = { fg = p.leaf },
    ["@markup.list.unchecked"] = { fg = p.muted },

    -- lsp ------------------------------------------------------------------
    LspReferenceText = { bg = p.overlay },
    LspReferenceRead = { bg = p.overlay },
    LspReferenceWrite = { bg = p.overlay, underline = true },
    LspInlayHint = { fg = p.muted, bg = p.surface },
    LspCodeLens = { fg = p.muted },
    LspCodeLensSeparator = { fg = p.hl_high },
    LspSignatureActiveParameter = { bg = p.hl_med, bold = true },
    LspInfoBorder = { link = "FloatBorder" },

    ["@lsp.type.boolean"] = { link = "@boolean" },
    ["@lsp.type.builtinType"] = { link = "@type.builtin" },
    ["@lsp.type.class"] = { link = "@type" },
    ["@lsp.type.comment"] = {}, -- defer to treesitter
    ["@lsp.type.decorator"] = { link = "@attribute" },
    ["@lsp.type.enum"] = { link = "@type" },
    ["@lsp.type.enumMember"] = { link = "@constant" },
    ["@lsp.type.escapeSequence"] = { link = "@string.escape" },
    ["@lsp.type.function"] = { link = "@function" },
    ["@lsp.type.interface"] = { link = "@type" },
    ["@lsp.type.keyword"] = { link = "@keyword" },
    ["@lsp.type.macro"] = { link = "@function.macro" },
    ["@lsp.type.method"] = { link = "@function.method" },
    ["@lsp.type.namespace"] = { link = "@module" },
    ["@lsp.type.number"] = { link = "@number" },
    ["@lsp.type.operator"] = { link = "@operator" },
    ["@lsp.type.parameter"] = { link = "@variable.parameter" },
    ["@lsp.type.property"] = { link = "@property" },
    ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" },
    ["@lsp.type.string"] = { link = "@string" },
    ["@lsp.type.struct"] = { link = "@type" },
    ["@lsp.type.type"] = { link = "@type" },
    ["@lsp.type.typeAlias"] = { link = "@type.definition" },
    ["@lsp.type.typeParameter"] = { link = "@type" },
    ["@lsp.type.variable"] = {}, -- defer to treesitter
    -- treesitter tags any capitalised lua name (e.g. a module table `M`) as a constant
    ["@lsp.type.variable.lua"] = { link = "@variable" },
    ["@lsp.typemod.variable.global.lua"] = { link = "@variable.builtin" },
    ["@lsp.typemod.class.defaultLibrary"] = { link = "@type.builtin" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.method.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.operator.injected"] = { link = "@operator" },
    ["@lsp.typemod.string.injected"] = { link = "@string" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.variable.injected"] = { link = "@variable" },

    -- diagnostics are filled in below

    -- health ---------------------------------------------------------------
    healthError = { fg = p.geranium },
    healthSuccess = { fg = p.leaf },
    healthWarning = { fg = p.ochre },

    -- gitsigns -------------------------------------------------------------
    GitSignsAdd = { fg = p.leaf },
    GitSignsChange = { fg = p.ochre },
    GitSignsDelete = { fg = p.geranium },
    GitSignsAddInline = { bg = tint(p.leaf, 0.32) },
    GitSignsChangeInline = { bg = tint(p.ochre, 0.28) },
    GitSignsDeleteInline = { bg = tint(p.geranium, 0.30) },
    GitSignsCurrentLineBlame = { fg = p.muted, italic = true },

    -- neo-tree (its fallbacks are hard-coded colours outside the palette) --
    NeoTreeGitAdded = { fg = p.leaf },
    NeoTreeGitModified = { fg = p.ochre },
    NeoTreeGitDeleted = { fg = p.geranium },
    NeoTreeGitRenamed = { fg = p.sage },
    NeoTreeGitUntracked = { fg = p.lilac, italic = true }, -- same hue as starship's `?`
    NeoTreeGitStaged = { fg = p.leaf },
    NeoTreeGitUnstaged = { fg = p.ochre },
    NeoTreeGitConflict = { fg = p.geranium, bold = true, italic = true },
    NeoTreeGitIgnored = { fg = p.muted },
    NeoTreeDotfile = { fg = p.muted },
    NeoTreeDimText = { fg = p.muted },
    NeoTreeFadeText1 = { fg = p.muted },
    NeoTreeFadeText2 = { fg = p.hl_high },
    NeoTreeIndentMarker = { fg = p.hl_high },
    NeoTreeExpander = { fg = p.muted },
    NeoTreeRootName = { fg = p.text, bold = true, italic = true },
    NeoTreeModified = { fg = p.leaf },
    NeoTreeMessage = { fg = p.muted, italic = true },
    NeoTreeFileStats = { fg = p.muted },
    NeoTreeFileStatsHeader = { fg = p.subtle, bold = true },
    NeoTreeTabActive = { fg = p.text, bg = bg, bold = true },
    NeoTreeTabInactive = { fg = p.muted, bg = p.surface },
    NeoTreeTabSeparatorActive = { fg = bg, bg = bg },
    NeoTreeTabSeparatorInactive = { fg = p.surface, bg = p.surface },

    -- snacks ---------------------------------------------------------------
    SnacksIndent = { fg = p.overlay },
    SnacksIndentScope = { fg = p.muted },
    SnacksIndentChunk = { fg = p.muted },
    SnacksDashboardHeader = { fg = p.forgetmenot },
    SnacksDashboardIcon = { fg = p.forgetmenot },
    SnacksDashboardKey = { fg = p.wallflower },
    SnacksDashboardDesc = { fg = p.text },
    SnacksDashboardFooter = { fg = p.muted },
    SnacksDashboardSpecial = { fg = p.lilac },
    SnacksDashboardDir = { fg = p.muted },
    SnacksDashboardFile = { fg = p.text },
    SnacksPickerMatch = { fg = p.ochre, bold = true },
    SnacksPickerDir = { fg = p.muted },
    SnacksPickerListCursorLine = { bg = p.overlay },
    SnacksPickerPreviewCursorLine = { bg = p.overlay },
    SnacksPickerPrompt = { fg = p.forgetmenot },
    SnacksPickerSelected = { fg = p.geranium },
    SnacksPickerTotals = { fg = p.muted },
    SnacksPickerTree = { fg = p.overlay },

    -- fzf-lua --------------------------------------------------------------
    FzfLuaNormal = { link = "NormalFloat" },
    FzfLuaBorder = { link = "FloatBorder" },
    FzfLuaTitle = { link = "FloatTitle" },
    FzfLuaCursorLine = { bg = p.overlay },
    FzfLuaFzfCursorLine = { fg = p.text, bg = p.overlay },
    FzfLuaFzfMatch = { fg = p.ochre, bold = true },
    FzfLuaFzfPrompt = { fg = p.forgetmenot },
    FzfLuaFzfPointer = { fg = p.geranium },
    FzfLuaFzfMarker = { fg = p.leaf },
    FzfLuaFzfInfo = { fg = p.muted },
    FzfLuaHeaderBind = { fg = p.wallflower },
    FzfLuaHeaderText = { fg = p.subtle },
    FzfLuaPathColNr = { fg = p.muted },
    FzfLuaPathLineNr = { fg = p.sage },
    FzfLuaBufFlagCur = { fg = p.ochre },
    FzfLuaBufFlagAlt = { fg = p.forgetmenot },

    -- blink.cmp ------------------------------------------------------------
    BlinkCmpMenu = { link = "Pmenu" },
    BlinkCmpMenuBorder = { link = "FloatBorder" },
    BlinkCmpMenuSelection = { link = "PmenuSel" },
    BlinkCmpScrollBarThumb = { link = "PmenuThumb" },
    BlinkCmpScrollBarGutter = { link = "PmenuSbar" },
    BlinkCmpLabel = { fg = p.text },
    BlinkCmpLabelMatch = { fg = p.ochre, bold = true },
    BlinkCmpLabelDeprecated = { fg = p.muted, strikethrough = true },
    BlinkCmpLabelDetail = { fg = p.muted },
    BlinkCmpLabelDescription = { fg = p.muted },
    BlinkCmpSource = { fg = p.muted },
    BlinkCmpGhostText = { fg = p.muted, italic = true },
    BlinkCmpDoc = { link = "NormalFloat" },
    BlinkCmpDocBorder = { link = "FloatBorder" },
    BlinkCmpDocSeparator = { fg = p.hl_high, bg = p.surface },
    BlinkCmpSignatureHelp = { link = "NormalFloat" },
    BlinkCmpSignatureHelpBorder = { link = "FloatBorder" },
    BlinkCmpSignatureHelpActiveParameter = { link = "LspSignatureActiveParameter" },

    -- which-key ------------------------------------------------------------
    WhichKey = { fg = p.forgetmenot },
    WhichKeyGroup = { fg = p.lilac },
    WhichKeyDesc = { fg = p.text },
    WhichKeySeparator = { fg = p.muted },
    WhichKeyValue = { fg = p.muted },
    WhichKeyNormal = { link = "NormalFloat" },
    WhichKeyBorder = { link = "FloatBorder" },
    WhichKeyTitle = { link = "FloatTitle" },

    -- flash ----------------------------------------------------------------
    FlashBackdrop = { fg = p.muted },
    FlashMatch = { fg = p.text, bg = p.hl_high },
    FlashCurrent = { fg = p.base, bg = p.ochre, bold = true },
    FlashLabel = { fg = p.base, bg = p.geranium, bold = true },

    -- noice ----------------------------------------------------------------
    NoiceCmdlineIcon = { fg = p.forgetmenot },
    NoiceCmdlineIconSearch = { fg = p.ochre },
    NoiceCmdlinePopupBorder = { link = "FloatBorder" },
    NoiceCmdlinePopupTitle = { link = "FloatTitle" },
    NoiceConfirmBorder = { link = "FloatBorder" },

    -- trouble --------------------------------------------------------------
    TroubleNormal = { fg = p.text, bg = p.surface },
    TroubleNormalNC = { fg = p.text, bg = p.surface },
    TroubleText = { fg = p.subtle },
    TroubleCount = { fg = p.lilac, bg = p.overlay },

    -- render-markdown ------------------------------------------------------
    RenderMarkdownCode = { bg = p.surface },
    RenderMarkdownCodeInline = { fg = p.leaf, bg = p.surface },
    RenderMarkdownBullet = { fg = p.lilac },
    RenderMarkdownQuote = { fg = p.subtle },
    RenderMarkdownDash = { fg = p.hl_high },
    RenderMarkdownLink = { fg = p.forgetmenot },
    RenderMarkdownChecked = { fg = p.leaf },
    RenderMarkdownUnchecked = { fg = p.muted },
    RenderMarkdownTodo = { fg = p.ochre },
    RenderMarkdownTableHead = { fg = p.hl_high },
    RenderMarkdownTableRow = { fg = p.hl_high },

    -- grug-far -------------------------------------------------------------
    GrugFarResultsMatch = { link = "Search" },
    GrugFarResultsPath = { fg = p.forgetmenot },
    GrugFarResultsLineNo = { fg = p.muted },
    GrugFarResultsLineColumn = { fg = p.muted },
    GrugFarInputLabel = { fg = p.lilac },
    GrugFarInputPlaceholder = { link = "Comment" },

    -- dap ------------------------------------------------------------------
    DapStoppedLine = { bg = tint(p.ochre, 0.15) },
    NvimDapVirtualText = { fg = p.muted, italic = true },

    -- mini.icons -----------------------------------------------------------
    MiniIconsAzure = { fg = p.forgetmenot },
    MiniIconsBlue = { fg = p.sky },
    MiniIconsCyan = { fg = p.sage },
    MiniIconsGreen = { fg = p.leaf },
    MiniIconsGrey = { fg = p.subtle },
    MiniIconsOrange = { fg = p.wallflower },
    MiniIconsPurple = { fg = p.lilac },
    MiniIconsRed = { fg = p.geranium },
    MiniIconsYellow = { fg = p.ochre },
  }

  for name, color in pairs(diag) do
    hl["Diagnostic" .. name] = { fg = color }
    hl["DiagnosticSign" .. name] = { fg = color }
    hl["DiagnosticFloating" .. name] = { fg = color }
    hl["DiagnosticVirtualText" .. name] = { fg = color }
    hl["DiagnosticVirtualLines" .. name] = { fg = color }
    hl["DiagnosticUnderline" .. name] = { sp = color, undercurl = true }
  end

  for i, color in ipairs(heading) do
    hl["@markup.heading." .. i] = { fg = color, bold = true }
    hl["@markup.heading." .. i .. ".markdown"] = { link = "@markup.heading." .. i }
    hl["@markup.heading." .. i .. ".marker.markdown"] = { link = "@markup.heading." .. i }
    hl["markdownH" .. i] = { link = "@markup.heading." .. i }
    hl["markdownH" .. i .. "Delimiter"] = { link = "@markup.heading." .. i }
    hl["RenderMarkdownH" .. i .. "Bg"] = { bg = tint(color, 0.15) }
  end

  -- which-key icons follow mini.icons
  for _, color in ipairs({ "Azure", "Blue", "Cyan", "Green", "Grey", "Orange", "Purple", "Red", "Yellow" }) do
    hl["WhichKeyIcon" .. color] = { link = "MiniIcons" .. color }
  end

  return hl
end

return M
