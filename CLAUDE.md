# CLAUDE.md - dotfiles

このリポジトリはmacOS/Linux環境のdotfiles管理用リポジトリです。

## 概要

GNU Stowを使ってシンボリックリンク方式で設定ファイルを管理し、新しいマシンで `./setup.sh` を実行するだけで環境を再現できるようにしています。

## ディレクトリ構成

```
dotfiles/
├── setup.sh                    # セットアップスクリプト
├── Brewfile                    # Homebrewパッケージ一覧
├── .gitignore
├── README.md
├── CLAUDE.md
├── zsh/                        # stowパッケージ: zsh
│   ├── .zshrc
│   └── .zshrc.local.example
├── git/                        # stowパッケージ: git
│   ├── .gitconfig
│   └── .gitconfig.local.example
├── nvim/                       # stowパッケージ: nvim
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/
│               ├── config/
│               └── plugins/
├── yazi/                       # stowパッケージ: yazi
│   └── .config/
│       └── yazi/
│           └── keymap.toml
└── mise/                       # stowパッケージ: mise
    └── .config/
        └── mise/
            └── config.toml
```

## 設計原則

### 1. 秘密情報の分離

トークンや個人情報は `.local` ファイルに分離し、git管理対象外とする。

```bash
# 良い例
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# 悪い例：直接書かない
export GITHUB_TOKEN="ghp_xxxxx"
```

### 2. 既存ファイルのスキップ

setup.sh実行時、既存ファイルがある場合はスキップしてログ出力する。

```bash
# stow --simulate でコンフリクトをチェック
if ! stow -d "$DOTFILES_DIR" -t "$HOME" --simulate "$pkg" 2>/dev/null; then
  echo "  [SKIP] $pkg: existing files found, skipping"
  return
fi
```

### 3. 冪等性

何度実行しても同じ結果になるようにする。

```bash
# 良い例：存在チェック
if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
fi

# 悪い例：毎回追記される
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
```

### 4. OS分岐

macOSとLinuxで処理を分ける。

```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  brew bundle --file="$DOTFILES_DIR/Brewfile"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  # Linux
  sudo apt install -y stow ripgrep fd-find
fi
```

### 5. GNU Stowによるシンボリックリンク管理

GNU Stowを使用してシンボリックリンクを管理する。各パッケージ（zsh, git, nvim等）は、展開後の構造をそのままディレクトリに持つ。

```bash
# $HOME直下に展開されるもの（zsh, git）
zsh/
└── .zshrc          → $HOME/.zshrc

# $HOME/.config以下に展開されるもの（nvim, yazi, mise）
nvim/
└── .config/
    └── nvim/
        └── init.lua  → $HOME/.config/nvim/init.lua
```

**stowコマンドの使い方**

```bash
# パッケージをリンク
stow -d ~/dotfiles -t "$HOME" zsh

# パッケージをアンリンク
stow -d ~/dotfiles -t "$HOME" -D zsh

# ドライラン（実行前に確認）
stow -d ~/dotfiles -t "$HOME" --simulate zsh
```

## setup.shの実装ルール

1. `set -e` でエラー時に即停止
2. `DOTFILES_DIR` は絶対パスで取得
3. stowがなければインストール
4. `stow --simulate` でコンフリクトチェック、既存ファイルがあればスキップ
5. `.local` ファイルは存在しない場合のみテンプレートからコピー
6. ログ出力で進捗を表示
7. 最後に次のステップを案内

## ファイル追加時のチェックリスト

新しい設定ファイルを追加する際：

- [ ] 適切なstowパッケージディレクトリに配置
  - `$HOME`直下のファイル: `パッケージ名/.ファイル名`
  - `$HOME/.config`以下: `パッケージ名/.config/アプリ名/ファイル`
- [ ] 秘密情報は `.local` ファイルに分離
- [ ] `.local.example` テンプレートを用意
- [ ] setup.shのPACKAGES配列にパッケージ名を追加
- [ ] .gitignoreに `.local` パターンを追加
- [ ] README.mdを更新

## Neovim (LazyVim) の構成

LazyVimをベースに、以下をカスタマイズ：

- `lua/plugins/lsp.lua` - LSPサーバー設定、ensure_installedで自動インストール
- `lua/plugins/editor.lua` - neo-tree, telescope設定
- `lua/plugins/ui.lua` - カラースキーム、インデントガイド
- `lua/plugins/treesitter.lua` - 構文ハイライト
- `lua/config/options.lua` - Neovimオプション
- `lua/config/keymaps.lua` - キーマップ

### プラグイン追加時の注意

- `opts` で既存設定をマージ（完全上書きしない）
- Masonパッケージは `ensure_installed` に追加
- リポジトリ名の変更に注意（例: `williamboman/mason.nvim` → `mason-org/mason.nvim`）

## コマンド

```bash
# セットアップ
./setup.sh

# Homebrewパッケージ更新
brew bundle --file=~/dotfiles/Brewfile

# Neovim LSP管理
nvim → :Mason

# 設定変更後の反映
source ~/.zshrc

# 特定パッケージのアンリンク
stow -d ~/dotfiles -t "$HOME" -D パッケージ名
```

## トラブルシューティング

### nvim初回起動でエラー

Masonの並列インストール競合。2回目の起動で解消される。

### stowでコンフリクトエラー

既存ファイルがある場合に発生。手動で削除またはバックアップしてから再実行。

```bash
# 既存ファイルを確認
ls -la ~/.zshrc

# バックアップして削除
mv ~/.zshrc ~/.zshrc.bak

# 再実行
./setup.sh
```

### シンボリックリンクが切れた

```bash
ls -la ~/.zshrc  # リンク先を確認
./setup.sh       # 再実行
```

### .localファイルを誤ってコミットした

```bash
git rm --cached <file>
# .gitignoreに追加されているか確認
```
