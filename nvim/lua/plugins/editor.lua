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
}
