return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",
        -- ZSH/Bash
        "bash-language-server",
        "shellcheck",
        "shfmt",
        -- shellcheck doesn't understand zsh syntax (false positives on
        -- zsh-only constructs); shuck is dialect-aware for bash/zsh/posix/mksh
        "shuck",
        -- Markdown
        "marksman",
        "markdownlint-cli2",
        -- JSON
        "json-lsp",
        "prettier",
        -- TOML
        "taplo",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
}
