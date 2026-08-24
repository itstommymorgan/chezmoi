return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		dependencies = { "rafamadriz/friendly-snippets", "Kaiser-Yang/blink-cmp-git" },

		version = "1.*", --force v1 while v2 is in heavy dev

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "super-tab" }, --tab to accept suggestion
			appearance = { nerd_font_variant = "mono" },
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "git" },
				providers = {
					git = {
						module = "blink-cmp-git",
						name = "Git",
						enabled = function()
							return vim.bo.filetype == "gitcommit"
						end,
						opts = {},
					},
				},
			},
		},
	},
}
