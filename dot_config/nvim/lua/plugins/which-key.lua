-- which-key.nvim - shows available keybindings in a popup as you type a
-- prefix (e.g. <Leader>), picking up existing `desc` fields automatically.
return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps (which-key)",
		},
	},
}
