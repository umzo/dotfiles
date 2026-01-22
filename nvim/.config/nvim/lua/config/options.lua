-- ~/.config/nvim/lua/config/options.lua
-- Neovimオプション（LazyVimデフォルトに追加/上書き）

local opt = vim.opt

-- インデント
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- 行番号
opt.number = true
opt.relativenumber = true

-- 検索
opt.ignorecase = true
opt.smartcase = true

-- UI
opt.scrolloff = 8 -- カーソル上下に常に8行表示
opt.signcolumn = "yes" -- サインカラムを常に表示
opt.cursorline = true -- カーソル行をハイライト

-- 折り返し
opt.wrap = false -- 行を折り返さない

-- クリップボード（システムと共有）
opt.clipboard = "unnamedplus"

-- アンドゥの永続化
opt.undofile = true
opt.undolevels = 10000
