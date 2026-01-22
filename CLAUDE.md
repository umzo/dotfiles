# CLAUDE.md - dotfiles

このリポジトリはmacOS/Linux環境のdotfiles管理用リポジトリです。

## 概要

シンボリックリンク方式で設定ファイルを管理し、新しいマシンで `./setup.sh` を実行するだけで環境を再現できるようにしています。

## ディレクトリ構成

```
dotfiles/
├── setup.sh                    # セットアップスクリプト
├── Brewfile                    # Homebrewパッケージ一覧
├── .gitignore
├── README.md
├── CLAUDE.md
├── zsh/
│   ├── .zshrc                  # Zsh設定
│   └── .zshrc.local.example    # ローカル設定テンプレート
├── nvim/                       # Neovim設定 (LazyVim)
│   ├── init.lua
│   └── lua/
│       ├── config/
│       └── plugins/
└── git/
    ├── .gitconfig              # Git設定
    └── .gitconfig.local.example
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

### 2. 既存ファイルのバックアップ

setup.sh実行時、既存ファイルは上書きせずバックアップを作成する。

```bash
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi
ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
```

### 3. 冪等性

何度実行しても同じ結果になるようにする。

```bash
# 良い例：存在チェック
if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES_DIR/.zshrc.local.example" "$HOME/.zshrc.local"
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
  sudo apt install -y ripgrep fd-find
fi
```

### 5. シンボリックリンク方式

コピーではなくシンボリックリンクを使用。変更が即座に反映される。

## setup.shの実装ルール

1. `set -e` でエラー時に即停止
2. `DOTFILES_DIR` は絶対パスで取得
3. 既存ファイルはバックアップしてからリンク作成
4. `.local` ファイルは存在しない場合のみテンプレートからコピー
5. ログ出力で進捗を表示
6. 最後に次のステップを案内

## ファイル追加時のチェックリスト

新しい設定ファイルを追加する際：

- [ ] 適切なディレクトリに配置（ツールごとに分ける）
- [ ] 秘密情報は `.local` ファイルに分離
- [ ] `.local.example` テンプレートを用意
- [ ] setup.shにバックアップ＆リンク処理を追加
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
```

## トラブルシューティング

### nvim初回起動でエラー

Masonの並列インストール競合。2回目の起動で解消される。

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
