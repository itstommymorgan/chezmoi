-- dual highlighting, safe masked formatting, template diagnostics, live
-- preview, and completion for chezmoi's *.tmpl source files
return {
	{
		"dpezto/chezmoi-template.nvim",
		lazy = false,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		---@module "chezmoi-template"
		---@type chezmoi-template.Config
		opts = {
			-- default is true; never auto-run `chezmoi apply` against ~ on save
			apply = { on_save = false },
			keymaps = { enabled = true },
		},
	},
}
