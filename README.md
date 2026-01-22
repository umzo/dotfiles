# dotfiles

My personal dotfiles.

## Setup

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

## 初回セットアップ（手動）

### 開発用APFSボリュームの作成

大文字/小文字を区別するAPFSボリュームを作成する：

**ディスクユーティリティを使用：**
1. ディスクユーティリティを開く
2. コンテナ（例: "Macintosh HD"）を選択
3. 「+」をクリックしてボリュームを追加
4. 名前: `Develop`
5. フォーマット: APFS（大文字/小文字を区別）
6. 暗号化: なし

**ターミナルを使用：**
```bash
# ディスク識別子を確認
diskutil list

# ボリュームを作成（disk3は環境に合わせて変更）
diskutil apfs addVolume disk3 "Case-sensitive APFS" Develop
```

ボリュームは `/Volumes/Develop` にマウントされる。

## Structure

```
dotfiles/
├── setup.sh              # セットアップスクリプト
├── Brewfile              # Homebrewパッケージ
├── zsh/
│   ├── .zshrc            # Zsh設定
│   └── .zshrc.local.example
├── nvim/                 # Neovim設定 (LazyVim)
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/
├── git/
│   ├── .gitconfig
│   └── .gitconfig.local.example
├── yazi/                 # Yaziファイルマネージャー設定
└── mise/
    └── config.toml       # mise設定（trusted_config_paths等）
```

## Local Settings

以下のファイルは `.gitignore` に含まれており、各マシンで個別に設定：

- `~/.zshrc.local` - トークン等の秘密情報
- `~/.gitconfig.local` - ユーザー名・メールアドレス

## Neovim

[LazyVim](https://www.lazyvim.org/) ベースの設定。

### LSP

初回起動時に以下が自動インストールされる：
- typescript-language-server
- tailwindcss-language-server
- gopls
- lua-language-server
- eslint_d
- prettierd
- stylua

追加は `:Mason` から。

### キーバインド

| キー | 動作 |
|------|------|
| `Space` | リーダーキー |
| `Space Space` | ファイル検索 |
| `Space e` | ファイルエクスプローラー |
| `Space f g` | grep検索 |
| `g d` | 定義ジャンプ |
| `K` | ホバー |
