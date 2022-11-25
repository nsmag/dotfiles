local t_setup, telescope = pcall(require, "telescope")
if not t_setup then
  return
end

local a_setup, actions = pcall(require, "telescope.actions")
if not a_setup then
  return
end

telescope.setup({
  defaults = {
    mappings = {
      i = {
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      },
    },
  },
})

telescope.load_extension("fzf")
