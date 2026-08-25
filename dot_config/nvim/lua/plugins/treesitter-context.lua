-- pins the enclosing function/class/block at the top of the window
-- while scrolling through its body
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		max_lines = 6, -- default is unbounded, which can eat half the screen
	},
	keys = {
		{
			"<leader>c",
			function()
				require("treesitter-context").go_to_context(vim.v.count1)
			end,
			desc = "Jump to context",
		},
	},
}
