-- support chezmoi dot_* files like they are the actual files
vim.filetype.add({
	pattern = {
		[".*/dot_(.+)"] = function(path, bufnr, name)
			return vim.filetype.match({ filename = "." .. name })
		end,
	},
})

-- Neovim's built-in markdown ftplugin reads these globals once, at load
-- time, so they must be set before any markdown buffer's FileType event
-- fires (after/ftplugin/markdown.lua would run too late for these two).
-- Enable its built-in fold-by-heading support (off by default).
vim.g.markdown_folding = 1
-- Keep the 2-space tabstop/shiftwidth/softtabstop from editing.lua instead
-- of the ftplugin's own 4-space "recommended style" (not a strong current
-- convention - markdownlint's own MD007 default is 2-space list indent).
vim.g.markdown_recommended_style = 0
