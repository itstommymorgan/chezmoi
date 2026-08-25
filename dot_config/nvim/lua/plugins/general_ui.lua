-- This file contains configuration for all plugins related to general (i.e. not
-- code-specific) editing in neovim.

return {
  -- statusline
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
  { "andymass/vim-matchup", event = { "BufReadPost", "BufNewFile" } },

  -- the theme - loaded eagerly since display.lua sets it as the
  -- colorscheme before lazy.nvim would ever fire a lazy trigger
  { "Mofiqul/dracula.nvim", name = "dracula", lazy = false, priority = 1000 },

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
    opts = function(_, opts)
      opts.filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          never_show = { ".git" },
        },
        -- oil.nvim owns `:e <dir>` instead (below); `-` is still
        -- the explicit way to reach neo-tree.
        hijack_netrw_behavior = "disabled",
      }
      opts.window = {
        mappings = {
          ["-"] = "close_window",
        },
      }

      -- Keeps LSP-tracked imports in sync when files are moved/renamed
      -- from the neo-tree file tree.
      local function on_move(data)
        Snacks.rename.on_rename_file(data.source, data.destination)
      end
      local events = require("neo-tree.events")
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
    end,
  },

  -- edit a directory like a normal buffer: add/delete lines to
  -- create/delete files, edit a line to rename, :w to commit.
  -- `:e <dir>` opens here (default_file_explorer); `<Leader>o` opens
  -- the current file's parent directory directly.
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<Leader>o", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
    opts = {
      default_file_explorer = true,
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
    keys = {
      { "<Leader>f", nil, desc = "Find..." },
      { "<Leader>f<Leader>", "<cmd>Telescope grep_string<cr>", desc = "Grep string under cursor" },
      { "<Leader>fb", "<cmd>Telescope buffers theme=ivy<cr>", desc = "Find buffers" },
      { "<Leader>ff", "<cmd>Telescope find_files theme=ivy<cr>", desc = "Find files" },
      { "<Leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<Leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help tags" },
      { "<Leader>fm", "<cmd>Telescope keymaps<cr>", desc = "Find keymaps" },
      { "<Leader>ft", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Find symbols (LSP)" },
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

  -- native FZF impl for Telescope. Declared as a top-level spec (in
  -- addition to being nested under telescope's own `dependencies`)
  -- because lazy.nvim only runs `build` hooks for top-level specs;
  -- `lazy = true` keeps it from independently forcing an eager load -
  -- it still loads whenever telescope does.
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },

  -- try to hide ansi escape codes
  { "powerman/vim-plugin-AnsiEsc", cmd = "AnsiEsc" },

  -- render markdown (headings, code blocks, tables, etc.) in-buffer
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ---@module "render-markdown"
    ---@type render.md.UserConfig
    opts = {},
  },
}
