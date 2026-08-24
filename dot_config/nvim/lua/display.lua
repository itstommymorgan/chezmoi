vim.o.background = "dark"
vim.cmd("silent! colorscheme dracula")

-- show matching brackets/etc
vim.o.showmatch = true
-- show filename in title string
vim.o.title = true

-- tmux fix (don't ask me, ask stack overflow)
vim.cmd([[
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
]])

-- always show at least 7 lines around the cursor
vim.o.scrolloff = 7

-- show whitespace by default
vim.o.list = true
local whitespacechars = "tab:▸ ,trail:•,precedes:«,extends:»"
vim.o.listchars = whitespacechars
