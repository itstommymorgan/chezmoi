-- Markdown-specific plugins. render-markdown.nvim (in-buffer rendering)
-- lives in general_ui.lua since it predates this per-filetype file.
return {
	{
		"dhruvasagar/vim-table-mode",
		ft = "markdown",
		init = function()
			-- default mappings live on <Leader>t*, which collides with the
			-- terminal-toggle prefix; bound instead via <LocalLeader>t in
			-- after/ftplugin/markdown.lua
			vim.g.table_mode_disable_mappings = 1
			vim.g.table_mode_disable_tableize_mappings = 1
		end,
	},
}
