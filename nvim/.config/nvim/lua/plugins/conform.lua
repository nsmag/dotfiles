-- Pick exactly one of oxfmt / prettier per file, based on the project:
--   1. Walk up from the file; the nearest formatter config wins
--      (oxfmt config, prettier config, or a "prettier" key in package.json).
--   2. No config found: use oxfmt if the project installs it locally
--      (node_modules/.bin/oxfmt) and prettier isn't installed.
--   3. Otherwise: prettier (LazyVim default).

local oxfmt_files = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }

local prettier_files = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.json5",
  ".prettierrc.yaml",
  ".prettierrc.yml",
  ".prettierrc.toml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  ".prettierrc.ts",
  ".prettierrc.cts",
  ".prettierrc.mts",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
  "prettier.config.ts",
  "prettier.config.cts",
  "prettier.config.mts",
}

local function exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function any_exists(dir, names)
  for _, name in ipairs(names) do
    if exists(dir .. "/" .. name) then
      return true
    end
  end
  return false
end

local function package_json_has_prettier(dir)
  local path = dir .. "/package.json"
  if not exists(path) then
    return false
  end
  local ok, data = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  return ok and type(data) == "table" and data.prettier ~= nil
end

local function dirs_upward(start)
  local dirs = { start }
  for dir in vim.fs.parents(start) do
    table.insert(dirs, dir)
  end
  return dirs
end

---@return "oxfmt"|"prettier"
local function pick_formatter(dirname)
  local dirs = dirs_upward(dirname)

  -- 1. Nearest config wins (oxfmt checked first if both live in one dir).
  for _, dir in ipairs(dirs) do
    if any_exists(dir, oxfmt_files) then
      return "oxfmt"
    end
    if any_exists(dir, prettier_files) or package_json_has_prettier(dir) then
      return "prettier"
    end
  end

  -- 2. No config: nearest local install wins.
  for _, dir in ipairs(dirs) do
    local has_oxfmt = exists(dir .. "/node_modules/.bin/oxfmt")
    local has_prettier = exists(dir .. "/node_modules/.bin/prettier")
    if has_oxfmt and not has_prettier then
      return "oxfmt"
    end
    if has_prettier then
      return "prettier"
    end
  end

  -- 3. Default.
  return "prettier"
end

-- Filetypes oxfmt formats beyond the JS/TS/JSON set the oxc extra registers.
local extra_oxfmt_fts = { "css", "scss", "less", "markdown", "markdown.mdx", "yaml", "html", "graphql", "vue" }

local function only_when(name, original)
  return function(self, ctx)
    if pick_formatter(ctx.dirname) ~= name then
      return false
    end
    return original == nil or original(self, ctx)
  end
end

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(extra_oxfmt_fts) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      if not vim.tbl_contains(opts.formatters_by_ft[ft], "oxfmt") then
        table.insert(opts.formatters_by_ft[ft], 1, "oxfmt")
      end
    end

    opts.formatters = opts.formatters or {}
    for _, name in ipairs({ "oxfmt", "prettier" }) do
      local formatter = opts.formatters[name] or {}
      formatter.condition = only_when(name, formatter.condition)
      opts.formatters[name] = formatter
    end
  end,
}
