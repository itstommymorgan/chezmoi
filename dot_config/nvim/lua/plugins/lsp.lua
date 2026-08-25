-- This file contains configuration for all lsp-related plugins.

return {
  -- LSP config
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      "mason-org/mason.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- surface LSP progress (indexing, installs, etc.) as notifications
      -- instead of nowhere; recipe from snacks.nvim's own notifier docs
      local progress = vim.defaulttable()
      vim.api.nvim_create_autocmd('LspProgress', {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          local value = ev.data.params.value
          if not client or type(value) ~= 'table' then
            return
          end
          local p = progress[client.id]

          for i = 1, #p + 1 do
            if i == #p + 1 or p[i].token == ev.data.params.token then
              p[i] = {
                token = ev.data.params.token,
                msg = ('[%3d%%] %s%s'):format(
                  value.kind == 'end' and 100 or value.percentage or 100,
                  value.title or '',
                  value.message and (' **%s**'):format(value.message) or ''
                ),
                done = value.kind == 'end',
              }
              break
            end
          end

          local msg = {}
          progress[client.id] = vim.tbl_filter(function(v)
            return table.insert(msg, v.msg) or not v.done
          end, p)

          local spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' }
          vim.notify(table.concat(msg, '\n'), 'info', {
            id = 'lsp_progress',
            title = client.name,
            opts = function(notif)
              notif.icon = #progress[client.id] == 0 and ' '
                or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
            end,
          })
        end,
      })

      -- Neovim core binds gr* to LSP requests (grn=rename, gra=code action,
      -- grr=references, gri=implementation, grt=type definition, gO=document
      -- symbols) but leaves definition/declaration/call-hierarchy unbound.
      -- Extend the same gr* "goto LSP request" convention to cover them.
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then
            return
          end
          local buf = args.buf
          local caps = client.server_capabilities

          if caps.definitionProvider then
            vim.keymap.set('n', 'grd', vim.lsp.buf.definition, { buffer = buf, desc = 'vim.lsp.buf.definition()' })
          end
          if caps.declarationProvider then
            vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { buffer = buf, desc = 'vim.lsp.buf.declaration()' })
          end
          if caps.callHierarchyProvider then
            vim.keymap.set(
              'n', 'grc', vim.lsp.buf.incoming_calls,
              { buffer = buf, desc = 'vim.lsp.buf.incoming_calls()' }
            )
            vim.keymap.set(
              'n', 'gro', vim.lsp.buf.outgoing_calls,
              { buffer = buf, desc = 'vim.lsp.buf.outgoing_calls()' }
            )
          end
        end,
      })
    end,
  },


  -- LSP signature completion support
  {
    'ray-x/lsp_signature.nvim',
    event = "LspAttach",
    config = true,
  },
}
