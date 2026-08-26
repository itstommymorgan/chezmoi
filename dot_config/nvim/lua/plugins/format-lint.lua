return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        bash = { "shfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        ruby = { "rubocop" },
        sh = { "shfmt" },
        -- explicit (not LSP fallback): chezmoi-template.nvim's masked-format
        -- bridge formats via a scratch buffer with no LSP attached
        toml = { "taplo" },
        yaml = { "prettier" },
        zsh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      -- shfmt's own dialect auto-detect goes off the literal filename (e.g.
      -- "dot_zshrc" in the chezmoi source tree misdetects as bash and errors
      -- on zsh-only syntax) - override with Neovim's own correct filetype
      formatters = {
        shfmt = {
          append_args = function(_, ctx)
            local dialect = ({ zsh = "zsh", bash = "bash", sh = "bash" })[vim.bo[ctx.buf].filetype]
            return dialect and { "-ln", dialect } or {}
          end,
        },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      -- reads stdin, so its config discovery only checks $PWD, not
      -- ancestors - point it at ours directly
      lint.linters["markdownlint-cli2"].args = {
        "--config",
        vim.fn.expand("~/.markdownlint-cli2.jsonc"),
        "-",
      }
      lint.linters_by_ft = {
        sh = { "shellcheck" },
        markdown = { "markdownlint-cli2" },
        ruby = { "rubocop" },
        yaml = { "yamllint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
