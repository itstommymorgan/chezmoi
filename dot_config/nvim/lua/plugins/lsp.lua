-- This file contains configuration flazyor all lsp-related plugins.

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
    config = true,
  },
}
