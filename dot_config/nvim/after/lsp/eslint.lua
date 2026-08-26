-- an after/lsp/<name>.lua file replaces on_attach entirely (functions
-- don't merge), and referencing vim.lsp.config.eslint from inside this
-- very file recurses infinitely (it's the lazy accessor that loads this
-- file) - so this replicates the base on_attach's one job (registering
-- :LspEslintFixAll) instead of trying to chain to it
return {
  on_attach = function(client, bufnr)
    vim.api.nvim_buf_create_user_command(bufnr, "LspEslintFixAll", function()
      client:request_sync("workspace/executeCommand", {
        command = "eslint.applyAllFixes",
        arguments = {
          { uri = vim.uri_from_bufnr(bufnr), version = vim.lsp.util.buf_versions[bufnr] },
        },
      }, nil, bufnr)
    end, {})

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "LspEslintFixAll",
    })
  end,
}
