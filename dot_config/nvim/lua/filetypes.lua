vim.filetype.add({
  pattern = {
    -- support chezmoi dot_* files like they are the actual files
    [".*/dot_(.+)"] = function(path, bufnr, name)
      return vim.filetype.match({ filename = "." .. name })
    end,
    -- hammerspoon's own config template; *.json.defaults isn't recognized
    -- by Neovim's *.json extension matching
    [".*%.json%.defaults"] = "json",
  },
})

-- must be set before markdown's FileType event fires; after/ftplugin runs too late
vim.g.markdown_folding = 1 -- built-in fold-by-heading, off by default
vim.g.markdown_recommended_style = 0 -- keep global 2-space, not the ftplugin's 4-space
