# dotfiles

My personal dotfiles.

## Setup

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x setup.sh
./setup.sh
```

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
└── git/
    ├── .gitconfig
    └── .gitconfig.local.example
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
