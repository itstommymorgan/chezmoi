-- pin a small set of files per-project and jump straight to them
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	event = "VeryLazy",
	opts = {},
	keys = {
		{ "<leader>m", nil, desc = "Harpoon" },
		{
			"<leader>ma",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Add file",
		},
		{
			"<leader>mm",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Toggle menu",
		},
		{
			"<leader>mn",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Next file",
		},
		{
			"<leader>mp",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Prev file",
		},
		{
			"<leader>1",
			function()
				require("harpoon"):list():select(1)
			end,
			desc = "Harpoon file 1",
		},
		{
			"<leader>2",
			function()
				require("harpoon"):list():select(2)
			end,
			desc = "Harpoon file 2",
		},
		{
			"<leader>3",
			function()
				require("harpoon"):list():select(3)
			end,
			desc = "Harpoon file 3",
		},
		{
			"<leader>4",
			function()
				require("harpoon"):list():select(4)
			end,
			desc = "Harpoon file 4",
		},
	},
}
