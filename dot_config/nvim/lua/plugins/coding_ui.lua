-- This file contains configuration for plugins that provide any kind of
-- interface/display specific to coding (or working in source control).

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
	},

	-- git signs in the gutter
	{
		"lewis6991/gitsigns.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
		opts = {},
	},

	-- Floating terminal windows
	"numToStr/FTerm.nvim",

	-- Git plugin
	{
		"tpope/vim-fugitive",
		dependencies = { "shumphrey/fugitive-gitlab.vim" },
	},

	-- Enables :GBrowse, autocomplete, etc. to pull from GitHub.
	"tpope/vim-rhubarb",

	-- rainbow delimiters
	"HiPhish/rainbow-delimiters.nvim",

	-- show indentation guidelines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
		---@module "ibl"
		---@type ibl.config
		config = function()
			require("ibl").setup()
		end,
	},

	-- pretty list
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = true,
	},

	-- Allow you to edit files directly from the quickfix results
	"stefandtw/quickfix-reflector.vim",

	-- Navigation breadcrumbs (for lualine)
	{
		"SmiteshP/nvim-navic",
		dependencies = { "neovim/nvim-lspconfig" },
		config = function()
			local navic = require("nvim-navic")
			navic.setup({
				depth_limit = 4,
				depth_limit_indicator = "…",
			})
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.documentSymbolProvider then
						navic.attach(client, args.buf)
					end
				end,
			})
		end,
	},
}
