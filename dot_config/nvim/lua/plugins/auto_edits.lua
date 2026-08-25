-- This file contains configuration information for plugins that perform
-- automatic edits (or other operations like ctags generation) based on context. Programmer's little helpers.
return {
	-- keep HTML/JSX/etc tags in sync (treesitter-based; replaces tagalong.vim)
	{
		"windwp/nvim-ts-autotag",
		event = "InsertEnter",
		opts = {},
	},

	-- automatically create matching pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		dependencies = { "nvim-treesitter" },
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Automatically add 'end' statements as appropriate (treesitter-based;
	-- replaces vim-endwise). Activates via a FileType autocmd registered on
	-- load, so it needs lazy.nvim's `ft` trigger (not `event`) - `ft`
	-- replays FileType for the buffer that triggered the load, so the
	-- current buffer isn't missed the way it would be with e.g. InsertEnter,
	-- which always fires after FileType has already come and gone.
	{
		"RRethy/nvim-treesitter-endwise",
		ft = { "ruby", "lua", "vim", "bash", "sh", "fish", "elixir", "julia" },
	},
}
