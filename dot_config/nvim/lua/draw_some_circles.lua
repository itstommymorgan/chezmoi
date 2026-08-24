-- This file will always be first in my nvim config, so anything that needs to
-- be done before ANYTHING else (or otherwise really basic setup) goes here.

-- declare a variable for all the filetypes we want to exclude from various
-- plugins
vim.g.tm_special_buffers = { "neo-tree", "fzf", "snacks_terminal", "snacks_dashboard" }

-- use <SPACE> for mapleader
vim.keymap.set("n", "<Space>", "<Nop>")
vim.g.mapleader = " "

-- Please don't abandon my poor buffers
vim.o.hidden = true

-- Don't wait forever for other keystrokes
vim.o.timeoutlen = 1000
vim.o.ttimeoutlen = 0

-- see help shortmess (different from hotmess, I guesss)
vim.o.shortmess = "atTIq"

-- enable the mouse (I know, I'm a terrible person)
vim.o.mouse = "a"

-- smart case sensitivity in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- temp/undo files for fun and profit
local backupdirs = "~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp"
vim.o.backupdir = backupdirs
vim.o.directory = backupdirs
vim.o.undodir = backupdirs
vim.o.undofile = true

-- stop annoying me when I open a file in two different vim sessions.
-- 'e' means Edit Anyway - help v:swapchoice for other options.
vim.cmd([[augroup SimultaneousEdits
  autocmd!
  autocmd SwapExists * :let v:swapchoice = 'e'
augroup END]])

-- use gui termcolors (for CHADTree, mostly)
vim.o.termguicolors = true

-- disable cecutil's keybindings since they overlap with some of mine
vim.g.no_cecutil_maps = "1"
