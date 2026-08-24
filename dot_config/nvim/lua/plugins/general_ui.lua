-- This file contains configuration for all plugins related to general (i.e. not
-- code-specific) editing in neovim.

return {
	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
		opts = {
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
				disabled_filetypes = {
					statusline = vim.g.tm_special_buffers,
					winbar = vim.g.tm_special_buffers,
				},
				always_divide_middle = true,
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {},
				lualine_x = { "encoding", "fileformat", "filetype" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {},
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
			winbar = {
				lualine_b = { "filename" },
				lualine_c = { "navic" },
			},
			inactive_winbar = {
				lualine_b = { "filename" },
				lualine_c = { "navic" },
			},
		},
	},

	--improves on matchit, adding a lot of text objects and some logic.
	"andymass/vim-matchup",

	-- the theme
	{ "dracula/vim", as = "dracula" },

	-- dashboard
	"glepnir/dashboard-nvim",

	-- smooth scrolling operations
	{
		"karb94/neoscroll.nvim",
		config = true,
	},

	-- file tree browser window
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		keys = {
			{ "-", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			filesystem = {
				filtered_items = {
					hide_dotfiles = false,
					never_show = { ".git" },
				},
			},
			window = {
				mappings = {
					["-"] = "close_window",
				},
			},
		},
	},

	-- fuzzy finder over lists
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			local actions = require("telescope.actions")
			local trouble = require("trouble.sources.telescope")

			require("telescope").setup({
				defaults = {
					mappings = {
						i = {
							["<c-t>"] = trouble.open,
							["<esc>"] = actions.close,
						},
						n = {
							["<c-t>"] = trouble.open,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--hidden",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
					},
				},
				pickers = {
					find_files = {
						hidden = true,
					},
				},
			})

			require("telescope").load_extension("fzf")
		end,
	},

	-- native FZF impl for Telescope
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

	-- try to hide ansi escape codes
	"powerman/vim-plugin-AnsiEsc",
}
