local config = require("config")

-- Leader-t toggles the floating terminal.
config.nmap("<Leader>t", ":lua Snacks.terminal.toggle()<CR>", { silent = true })

-- Leader-z toggles a scratch buffer. Temporary spot for this keybinding -
-- revisit when keybinds get reorganized.
config.nmap("<Leader>z", ":lua Snacks.scratch()<CR>", { silent = true })
