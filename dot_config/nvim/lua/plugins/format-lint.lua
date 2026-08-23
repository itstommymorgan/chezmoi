return {
  {
    'stevearc/conform.nvim',
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
      lint.linters_by_ft = {
        sh = { 'shellcheck' },
      }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
