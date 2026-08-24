-- This file contains configuration for all lsp-related plugins.

return {
  -- LSP config
  { 
    'neovim/nvim-lspconfig',
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
  },
  

  -- LSP signature completion support
  {
    'ray-x/lsp_signature.nvim',
    event = "LspAttach",
    config = true,
  },
}
