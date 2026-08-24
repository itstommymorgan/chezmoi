local config = require("config")

config.nmap("<Leader>f<Leader>", "<cmd>Telescope grep_string<cr>")
config.nmap("<Leader>fb", "<cmd>Telescope buffers theme=ivy<cr>")
config.nmap("<Leader>ff", "<cmd>Telescope find_files theme=ivy<cr>")
config.nmap("<Leader>fg", "<cmd>Telescope live_grep<cr>")
config.nmap("<Leader>fh", "<cmd>Telescope help_tags<cr>")
config.nmap("<Leader>fm", "<cmd>Telescope keymaps<cr>")
config.nmap("<Leader>ft", "<cmd>Telescope tags<cr>")
