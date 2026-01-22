-- ~/.config/nvim/lua/config/keymaps.lua
-- カスタムキーマップ（LazyVimデフォルトに追加）

local map = vim.keymap.set

-- 保存
map("n", "<C-s>", "<cmd>w<cr>", { desc = "Save file" })
map("i", "<C-s>", "<esc><cmd>w<cr>", { desc = "Save file" })

-- 行の移動（Alt + j/k）はLazyVimデフォルトで設定済み

-- ウィンドウ分割
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })

-- バッファ操作
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- ターミナル
map("n", "<leader>tt", "<cmd>terminal<cr>", { desc = "Open terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- 検索ハイライトをクリア
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
