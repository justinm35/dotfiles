return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local mason_lspconfig = require("mason-lspconfig")
      require("mason").setup()
      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true })
        end
        map("n", "gd", vim.lsp.buf.definition)
        map("n", "gr", vim.lsp.buf.references)
        map("n", "K", vim.lsp.buf.hover)
      end

      mason_lspconfig.setup({
        ensure_installed = {
          "eslint",
          "vtsls",
          "pyright",
          "lua_ls",
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              capabilities = capabilities,
              on_attach = on_attach,
            })
          end,
        },
      })

      vim.diagnostic.config({
        underline = true,
        float = {
          focusable = false,
          source = "if_many",
          border = "single",
          prefix = "",
        },
      })

      vim.o.updatetime = 300
      vim.api.nvim_create_autocmd("CursorHold", {
        callback = function()
          vim.diagnostic.open_float(nil, {
            focusable    = true,
            source       = "if_many",
            prefix       = "",
            scope        = "cursor",
            border       = "single",
            close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
            format       = function(diagnostic)
              return "  " .. diagnostic.message .. "  "
            end,
          })
        end,
      })
    end,
  },
}
