-- snacks.nvim - collection of QoL plugins

-- Reads the current harpoon2 list into snacks.picker items, so the
-- dashboard's "Bookmarks" entry (below) shows harpoon marks instead of
-- vim marks. harpoon2 is lazy-loaded on VeryLazy (see plugins/harpoon.lua),
-- which fires well before this could ever run.
local function harpoon_items()
	local harpoon = require("harpoon")
	local list = harpoon:list()
	local items = {}
	for i = 1, list:length() do
		local item = list.items[i]
		if item then
			items[#items + 1] = {
				text = i .. " " .. item.value,
				file = item.value,
				pos = { (item.context and item.context.row) or 1, (item.context and item.context.col) or 0 },
			}
		end
	end
	return items
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	keys = {
		{ "<Leader>t", function() Snacks.terminal.toggle() end, desc = "Toggle terminal" },
		{ "<Leader>z", function() Snacks.scratch() end, desc = "Toggle scratch buffer" },
		-- <Leader>g* terminal helpers: the plain Git commands (b/d/l/s)
		-- live on the vim-fugitive spec instead.
		{ "<Leader>go", function() Snacks.gitbrowse() end, desc = "Git browse" },
		{
			"<Leader>gp",
			-- Runs through an interactive shell (-ic) so aliases like `gp`
			-- resolve. A second, distinct Snacks terminal (count = 2) keeps
			-- this separate from the plain <Leader>t shell - terminal
			-- identity is based on cmd/cwd/env/count, see docs/terminal.md.
			function()
				Snacks.terminal({ vim.o.shell, "-ic", "gp" }, { count = 2, auto_close = false })
			end,
			desc = "Git push (gp alias)",
		},
		{ "<Leader>gt", function() Snacks.terminal.toggle(nil, { count = 2 }) end, desc = "Git terminal" },
		{
			"<Leader>gu",
			function()
				Snacks.terminal({ vim.o.shell, "-ic", "git-smart-sync" }, { count = 2, auto_close = false })
			end,
			desc = "git-smart-sync",
		},
	},
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
							Snacks.picker.pick({
								title = "Harpoon",
								finder = harpoon_items,
								format = "file",
							})
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
