local config = require("config")

-- use <Leader>g as the start of all our chords
local function fugitive_bind(key, action)
	key = "<Leader>g" .. key
	config.map(key, action)
end

-- <chord>b for blame
fugitive_bind("b", ":Git blame<CR>")

-- <chord>d for diff
fugitive_bind("d", ":Gdiff<CR>")

-- <chord>l for log
fugitive_bind("l", ":Git log<CR>")

-- <chord>o for open (browse), replacing vim-rhubarb's :GBrowse
fugitive_bind("o", ":lua Snacks.gitbrowse()<CR>")

-- <chord>p for push. Runs through an interactive shell (-ic) so aliases
-- like `gp` resolve, matching how FTerm's :run() typed into an
-- already-running interactive shell. A second, distinct Snacks terminal
-- (count = 2) keeps this separate from the plain <Leader>t shell - terminal
-- identity is based on cmd/cwd/env/count, see docs/terminal.md.
fugitive_bind("p", ':lua Snacks.terminal({vim.o.shell, "-ic", "gp"}, {count = 2, auto_close = false})<CR>')

-- <chord>s for status
fugitive_bind("s", ":Git<CR>")

-- <chord>t to open the git terminal
fugitive_bind("t", ":lua Snacks.terminal.toggle(nil, {count = 2})<CR>")

-- <chord>u for git-up
fugitive_bind(
	"u",
	':lua Snacks.terminal({vim.o.shell, "-ic", "git-smart-sync"}, {count = 2, auto_close = false})<CR>'
)
