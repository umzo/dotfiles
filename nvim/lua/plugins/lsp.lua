-- ~/.config/nvim/lua/plugins/lsp.lua
-- LSP関連のカスタマイズ

return {
  -- Masonで自動インストールするLSP/ツールを指定
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP
        "typescript-language-server",
        "tailwindcss-language-server",
        "gopls",
        "lua-language-server",
        -- Linter
        "eslint_d",
        -- Formatter
        "prettierd",
        "stylua",
      },
    },
  },

  -- LSPサーバーの設定
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- TypeScript
        ts_ls = {
          settings = {
            completions = {
              completeFunctionCalls = true,
            },
          },
        },
        -- Tailwind CSS
        tailwindcss = {},
        -- Go
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },
      },
    },
  },

  -- フォーマッター設定
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        lua = { "stylua" },
      },
    },
  },
}
