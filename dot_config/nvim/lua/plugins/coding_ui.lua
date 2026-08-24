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

	-- Git plugin
	{
		"tpope/vim-fugitive",
		dependencies = { "shumphrey/fugitive-gitlab.vim" },
		-- <Leader>g* is the git chord prefix; the terminal-based half
		-- (o/p/t/u) lives on the snacks.nvim spec instead, since those
		-- call Snacks.terminal/gitbrowse rather than fugitive commands.
		keys = {
			{ "<Leader>gb", ":Git blame<CR>", mode = "", desc = "Git blame" },
			{ "<Leader>gd", ":Gdiff<CR>", mode = "", desc = "Git diff" },
			{ "<Leader>gl", ":Git log<CR>", mode = "", desc = "Git log" },
			{ "<Leader>gs", ":Git<CR>", mode = "", desc = "Git status" },
		},
	},

	-- rainbow delimiters
	"HiPhish/rainbow-delimiters.nvim",

	-- pretty list
	{
		"folke/trouble.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = true,
		keys = {
			{ "ge", ":Trouble diagnostics toggle<CR>", mode = "", desc = "Diagnostics (Trouble)" },
			{ "gr", ":Trouble lsp_references toggle<CR>", mode = "", desc = "LSP references (Trouble)" },
		},
	},

	-- better quickfix
	{
		"stevearc/quicker.nvim",
		ft = "qf",
		opts = {
			keys = {
				{
					">",
					function()
						require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
					end,
					desc = "Expand quickfix context",
				},
				{
					"<",
					function()
						require("quicker").collapse()
					end,
					desc = "Collapse quickfix context",
				},
			},
		},
	},

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
