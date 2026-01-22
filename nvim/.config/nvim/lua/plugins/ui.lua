-- ~/.config/nvim/lua/plugins/ui.lua
-- 見た目のカスタマイズ

return {
  -- カラースキーム（好みで変更）
  -- LazyVimデフォルトはtokyonight
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night", -- night, storm, day, moon
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
  },

  -- 別のカラースキームを使いたい場合
  -- {
  --   "catppuccin/nvim",
  --   name = "catppuccin",
  --   priority = 1000,
  --   opts = {
  --     flavour = "mocha", -- latte, frappe, macchiato, mocha
  --   },
  -- },
  -- {
  --   "LazyVim/LazyVim",
  --   opts = {
  --     colorscheme = "catppuccin",
  --   },
  -- },

  -- インデントガイド（v3）
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "│",
      },
      scope = {
        enabled = true,
      },
    },
  },

  -- バッファライン（上部のタブ）を無効化したい場合
  -- {
  --   "akinsho/bufferline.nvim",
  --   enabled = false,
  -- },
}
