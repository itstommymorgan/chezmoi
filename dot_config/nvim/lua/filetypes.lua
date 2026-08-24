-- support chezmoi dot_* files like they are the actual files
vim.filetype.add({
	pattern = {
		[".*/dot_(.+)"] = function(path, bufnr, name)
			return vim.filetype.match({ filename = "." .. name })
		end,
	},
})
