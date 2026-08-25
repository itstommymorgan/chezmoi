-- Markdown-specific plugins.
return {
	{
		"dhruvasagar/vim-table-mode",
		ft = "markdown",
		init = function()
			-- default mappings collide with the terminal-toggle prefix
			-- (<Leader>t*); bound instead via <LocalLeader>t in the ftplugin
			vim.g.table_mode_disable_mappings = 1
			vim.g.table_mode_disable_tableize_mappings = 1
		end,
	},
}
