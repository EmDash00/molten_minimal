local vimp = require('vimp')
local lspconfig = require('lspconfig')
local nnoremap = vimp.nnoremap

local api = vim.api
local diagnostic, lsp = vim.diagnostic, vim.lsp

vim.o.updatetime = 250

diagnostic.config {
  virtual_text = false,
  signs = true,
  underline = true,
  float = {
    border = 'rounded'
  },
  update_in_insert = false,
  severity_sort = true
}

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local opts = { 'silent' }


-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.lsp.omnifunc')

  vimp.add_buffer_maps(
    bufnr,
    function()
      -- Mappings.
      -- See `:help lsp.*` for documentation on any of the below functions
      nnoremap(opts, '<leader>j', diagnostic.goto_next)
      nnoremap(opts, '<leader>k', diagnostic.goto_prev)
      nnoremap(opts, '<leader>J', function() diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } }) end)
      nnoremap(opts, '<leader>K', function() diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } }) end)

      nnoremap(opts, 'gD', lsp.buf.declaration)
      nnoremap(opts, 'gd', lsp.buf.definition)
      nnoremap(
        opts, 'L',
        function()
          api.nvim_command('set eventignore=CursorHold')
          lsp.buf.hover()
          api.nvim_command('autocmd CursorMoved <buffer> ++once set eventignore=""')
        end
      )
      nnoremap(opts, 'gi', lsp.buf.implementation)

      nnoremap(opts, '<leader>h', lsp.buf.signature_help)
      nnoremap(opts, '<leader>wa', lsp.buf.add_workspace_folder)
      nnoremap(opts, '<leader>wr', lsp.buf.remove_workspace_folder)
      nnoremap(
        opts,
        '<leader>wl',
        function()
          print(vim.inspect(lsp.buf.list_workspace_folders()))
        end
      )
      nnoremap(opts, 'td', lsp.buf.type_definition)
      nnoremap(opts, '<leader>rn', lsp.buf.rename)
      --nnoremap(opts, '<leader>ac', lsp.buf.code_action)
      nnoremap(opts, 'gr', lsp.buf.references)
      nnoremap(opts, '<leader>f', lsp.buf.format)
    end
)

  if client.server_capabilities.documentHighlightProvider then
    vim.cmd [[
      hi link LspReferenceRead Visual
      hi link LspReferenceText Visual
      hi link LspReferenceWrite Visual
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd! CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd! CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd! CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]]
  end

  -- Diagnostic hold
  vim.api.nvim_create_autocmd(
    "CursorHold",
    {
      buffer = bufnr,
      callback = function()
        diagnostic.open_float(
          nil,
          {
            focusable = false,
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            source = 'always',
            prefix = ' ',
            suffix = '',
            scope = 'cursor',
          }
        )
      end
    }
  )
end

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.max_height = 30
  opts.max_width = 80
  opts.border = opts.border or 'rounded'
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

local lsp_flags = {
  debounce_text_changes = 150,
}

--local capabilities = require('cmp_nvim_lsp').update_capabilities(
  --lsp.protocol.make_client_capabilities()
--)
--
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = { 'utf-16' }

lspconfig.pyright.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}

lspconfig.serve_d.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}

lspconfig.clangd.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}

lspconfig.tsserver.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  settings = {
    ["rust-analyzer"] = {}
  },
  capabilities = capabilities
}

require'lspconfig'.texlab.setup{
  on_attach=on_attach,
  flags=lsp_flags,
  capabilities=capabilities,
}

require'lspconfig'.jdtls.setup{
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}

require 'lspconfig'.lua_ls.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
  --capabilities = capabilities
}

require 'lspconfig'.vimls.setup {
  on_attach = on_attach,
  flags = lsp_flags,
  capabilities = capabilities
}
