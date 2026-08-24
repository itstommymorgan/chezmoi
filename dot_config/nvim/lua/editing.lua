-- sane tab defaults
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

-- don't wrap in the middle of a word
vim.o.linebreak = true
-- 80-char line length
vim.o.textwidth = 80

-- format options, see help fo-table
vim.o.formatoptions = "tcqnbl1j"

-- automatically restore the cursor position when reopening a file, if possible.
vim.cmd([[autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \ exe "normal! g`\"" |
  \ endif]])
