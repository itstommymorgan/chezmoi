-- nvim-treesitter-context - pins the enclosing function/class/block at the
-- top of the window while you scroll through its body.
return {
	"nvim-treesitter/nvim-treesitter-context",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		-- unbounded by default, which can eat half the screen in deeply
		-- nested code; cap it to a handful of stacked context lines
		max_lines = 6,
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
