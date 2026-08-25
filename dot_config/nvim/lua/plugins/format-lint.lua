return {
  {
    'stevearc/conform.nvim',
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        bash = { "shfmt" },
        lua = { "stylua" },
        sh = { "shfmt" },
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
      -- markdownlint-cli2 is invoked over stdin (no file path), so its
      -- automatic config discovery only ever checks $PWD, never an
      -- ancestor directory - it would silently miss ~/.markdownlint-cli2.jsonc
      -- for any file not directly in $HOME. Point it there explicitly instead.
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
