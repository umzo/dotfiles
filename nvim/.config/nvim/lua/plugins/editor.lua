-- ~/.config/nvim/lua/plugins/editor.lua
-- エディタ関連のカスタマイズ

return {
  -- ファイルエクスプローラー（neo-tree）の設定
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          visible = true, -- 隠しファイルを表示
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            "node_modules",
            ".git",
          },
        },
      },
    },
  },

  -- Telescope（ファジーファインダー）の設定
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        file_ignore_patterns = {
          "node_modules",
          ".git/",
          "dist/",
          "build/",
        },
      },
    },
  },

  -- which-key（キーバインドヘルプ）の遅延を短く
  {
    "folke/which-key.nvim",
    opts = {
      delay = 300, -- デフォルトは500ms
    },
  },

  -- flash.nvim（高速モーション）
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- Markdownプレビュー（markdown-preview.nvim）
  -- mermaid, KaTeX, 画像対応
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_close = 0
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview<cr>", desc = "Preview Markdown" },
    },
  },
}
