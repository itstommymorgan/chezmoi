return {
  {
    'stevearc/conform.nvim',
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        bash = { "shfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        sh = { "shfmt" },
        -- explicit (not LSP fallback): chezmoi-template.nvim's masked-format
        -- bridge formats via a scratch buffer with no LSP attached
        toml = { "taplo" },
        zsh = { "shfmt" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
    },
  },

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost' },
    config = function()
      local lint = require('lint')
      -- reads stdin, so its config discovery only checks $PWD, not
      -- ancestors - point it at ours directly
      lint.linters['markdownlint-cli2'].args = {
        '--config', vim.fn.expand('~/.markdownlint-cli2.jsonc'),
        '-',
      }
      lint.linters_by_ft = {
        sh = { 'shellcheck' },
        markdown = { 'markdownlint-cli2' },
      }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
