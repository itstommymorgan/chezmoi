-- This file contains configuration for plugins that provide any kind of
-- interface/display specific to coding (or working in source control).

return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			-- jsonc filetype maps to this same grammar, no separate parser exists
			require("nvim-treesitter").install({ "json" })

			-- folds start open; foldmethod=expr defaults to all-closed otherwise
			vim.o.foldlevelstart = 99

			-- generic: highlighting + folding for any filetype with an
			-- installed parser, silently a no-op otherwise
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					if pcall(vim.treesitter.start) then
						vim.wo[0][0].foldmethod = "expr"
						vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
					end
				end,
			})
		end,
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
		keys = {
			{ "<Leader>g", nil, desc = "Git" },
			{ "<Leader>gb", ":Git blame<CR>", mode = "", desc = "Git blame" },
			{ "<Leader>gD", ":Gdiff<CR>", mode = "", desc = "Git diff (current buffer)" },
			{ "<Leader>gl", ":Git log<CR>", mode = "", desc = "Git log" },
			{ "<Leader>gs", ":Git<CR>", mode = "", desc = "Git status" },
		},
	},

	-- whole-changeset diff/merge/history viewer
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
		-- toggles a list panel rather than jumping to a location, so it's
		-- kept out of the gr* family
		keys = {
			{ "<Leader>p", nil, desc = "Project" },
			{ "<Leader>pd", ":Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
			{ "<Leader>pr", ":Trouble lsp_references toggle<CR>", desc = "LSP references (Trouble)" },
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

	-- keyboard-driven popup for browsing/jumping the current file's LSP
	-- symbol tree, built on nvim-navic above
	{
		"hasansujon786/nvim-navbuddy",
		dependencies = {
			"neovim/nvim-lspconfig",
			"SmiteshP/nvim-navic",
			"MunifTanjim/nui.nvim",
		},
		opts = { lsp = { auto_attach = true } },
		keys = {
			{
				"<Leader>n",
				function()
					require("nvim-navbuddy").open()
				end,
				desc = "Navbuddy",
			},
		},
	},
}
