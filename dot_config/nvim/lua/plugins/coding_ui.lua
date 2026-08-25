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
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		config = true,
		opts = {},
	},

	-- Git plugin
	{
		"tpope/vim-fugitive",
		-- <Leader>g* is the git chord prefix; the terminal-based half
		-- (o/p/t/u) lives on the snacks.nvim spec instead, since those
		-- call Snacks.terminal/gitbrowse rather than fugitive commands.
		-- gd/gh are diffview.nvim below, not fugitive.
		keys = {
			{ "<Leader>g", nil, desc = "Git" },
			{ "<Leader>gb", ":Git blame<CR>", mode = "", desc = "Git blame" },
			{ "<Leader>gD", ":Gdiff<CR>", mode = "", desc = "Git diff (current buffer)" },
			{ "<Leader>gl", ":Git log<CR>", mode = "", desc = "Git log" },
			{ "<Leader>gs", ":Git<CR>", mode = "", desc = "Git status" },
		},
	},

	-- whole-changeset diff/merge/history viewer: a file panel across every
	-- changed file, vs. fugitive's single-buffer :Gdiff (<Leader>gD above)
	{
		"sindrets/diffview.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = {
			"DiffviewOpen",
			"DiffviewClose",
			"DiffviewFileHistory",
			"DiffviewToggleFiles",
			"DiffviewFocusFiles",
			"DiffviewRefresh",
		},
		opts = {},
		keys = {
			{ "<Leader>gd", ":DiffviewOpen<CR>", mode = "", desc = "Diff all changes" },
			{ "<Leader>gh", ":DiffviewFileHistory %<CR>", mode = "", desc = "File history" },
		},
	},

	-- rainbow delimiters
	{ "HiPhish/rainbow-delimiters.nvim", event = { "BufReadPost", "BufNewFile" } },

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
		event = "LspAttach",
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
