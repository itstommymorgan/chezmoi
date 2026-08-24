-- snacks.nvim - collection of QoL plugins
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		quickfile = { enabled = true },
		scroll = { enabled = true },
		indent = { enabled = true },
		words = { enabled = true },
		terminal = {
			win = {
				position = "float",
				width = 0.8,
				height = 0.8,
				border = "rounded",
			},
		},
		gitbrowse = {},
		dashboard = {
			enabled = true,
			preset = {
				keys = {
					{
						icon = " ",
						key = "f",
						desc = "Find File",
						action = function()
							Snacks.dashboard.pick("files")
						end,
					},
					{
						icon = " ",
						key = "h",
						desc = "Find History",
						action = function()
							Snacks.dashboard.pick("oldfiles")
						end,
					},
					{
						icon = " ",
						key = "w",
						desc = "Find Word",
						action = function()
							Snacks.dashboard.pick("live_grep")
						end,
					},
					{
						icon = " ",
						key = "b",
						desc = "Bookmarks",
						action = function()
							Snacks.dashboard.pick("marks")
						end,
					},
					{
						icon = " ",
						key = "c",
						desc = "Change Colorscheme",
						action = function()
							Snacks.dashboard.pick("colorscheme")
						end,
					},
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
				},
			},
		},
	},
}
