-- <Leader><Leader> is a shortcut for commands
vim.keymap.set("n", "<Leader><Leader>", ":", { desc = "Command-line" })

-- <Leader>w writes the current buffer to disk
vim.keymap.set("", "<Leader>w", ":w!<CR>", { desc = "Write buffer" })

-- <Leader>q quits the current window
vim.keymap.set("", "<Leader>q", ":q!<CR>", { desc = "Quit window" })

-- <Leader>Q quits all windows
vim.keymap.set("", "<Leader>Q", ":qa!<CR>", { desc = "Quit all windows" })

-- <Leader>h/j/k/l navigates windows
local window_keys = { "h", "j", "k", "l", "H", "J", "K", "L" }
for count = 1, #window_keys do
	local key = window_keys[count]
	vim.keymap.set("", "<Leader>" .. key, "<C-W>" .. key, { desc = "Window " .. key })
end

-- use <Leader>s for vertical split, <Leader>S for horizontal split
vim.keymap.set("", "<Leader>s", ":vs<CR><C-W>l", { desc = "Vertical split" })
vim.keymap.set("", "<Leader>S", ":sp<CR><C-W>j", { desc = "Horizontal split" })

-- use <Leader>b to switch back to the last buffer you were looking at.
vim.keymap.set("", "<Leader>b", "<C-^>", { desc = "Switch to last buffer" })

-- reload vim config with <Leader>V
vim.keymap.set("", "<Leader>V", ":so ~/.config/nvim/init.lua<CR>", { desc = "Reload config" })

-- make Y behave like D, A, I, etc.
vim.keymap.set("", "Y", "y$", { desc = "Yank to end of line" })

-- make Q repeat the last recorded macro
vim.keymap.set("", "Q", "@@", { desc = "Repeat last macro" })

-- use <Leader>i to toggle display of hidden characters
vim.keymap.set("", "<Leader>i", ":set list!<CR>", { desc = "Toggle hidden characters" })

-- Hit escape twice to clear highlights (normal only)
vim.keymap.set("n", "<Esc><Esc>", ":nohls<CR>", { silent = true, desc = "Clear search highlight" })
vim.keymap.set("n", "<C-@><C-@>", ":nohls<CR>", { silent = true, desc = "Clear search highlight" })
vim.keymap.set("n", "<C-Space><C-Space>", ":nohls<CR>", { silent = true, desc = "Clear search highlight" })

--  keep search results in the center of the screen
local search_keys = { "n", "N", "*", "#", "g*", "g#" }
for count = 1, #search_keys do
	local key = search_keys[count]
	vim.keymap.set("n", key, key .. "zz", { silent = true, remap = true })
end
