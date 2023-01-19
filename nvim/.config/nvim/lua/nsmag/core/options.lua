local opt = vim.opt

-- line numbers
opt.number = true
opt.relativenumber = true

-- scroll
opt.scrolloff = 8

-- indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search
opt.ignorecase = true
opt.smartcase = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.list = true
opt.listchars = {
	tab = "  →",
	trail = "·",
}

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

-- keywords
opt.iskeyword:append("-")

-- complete
opt.completeopt = "menu,menuone,noselect"
