# dotfiles

macOS/Linux環境のdotfiles管理用リポジトリ。GNU Stowを使用してシンボリックリンク方式で設定ファイルを管理。

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
├── macos.sh              # macOS設定スクリプト
├── Brewfile              # Homebrewパッケージ
├── zsh/
│   ├── .zshrc
│   └── .zshrc.local.example
├── git/
│   ├── .gitconfig
│   └── .gitconfig.local.example
├── nvim/                 # Neovim設定 (LazyVim)
│   └── .config/nvim/
│       ├── init.lua
│       └── lua/
│           ├── config/
│           └── plugins/
├── tmux/
│   └── .tmux.conf
├── yazi/                 # Yaziファイルマネージャー設定
│   └── .config/yazi/
│       └── keymap.toml
├── mise/                 # miseランタイムマネージャー設定
│   └── .config/mise/
│       └── config.toml
├── starship/             # Starshipプロンプト設定
│   └── .config/starship.toml
├── sheldon/              # Zshプラグインマネージャー設定
│   └── .config/sheldon/
│       └── plugins.toml
├── iterm2/               # iTerm2設定
│   └── .config/iterm2/
│       └── com.googlecode.iterm2.plist
└── bat/                  # bat設定
    └── .config/bat/
        └── config
```

## Local Settings

以下のファイルは `.gitignore` に含まれており、各マシンで個別に設定：

- `~/.zshrc.local` - トークン等の秘密情報
- `~/.gitconfig.local` - ユーザー名・メールアドレス

## Homebrew Packages

| カテゴリ | パッケージ |
|---------|-----------|
| CLI Tools | git, neovim, ripgrep, fd, fzf, tree-sitter, colordiff, jq, yq, eza, bat, wget, tmux, btop, direnv, starship |
| Runtime Manager | mise |
| Development | gh (GitHub CLI), lazygit |
| File Manager | yazi, zoxide |
| Plugin Manager | sheldon |
| Browsers | google-chrome, microsoft-edge |
| Utilities | defaultbrowser, raycast |
| Applications | docker, zed, slack |
| Terminal | iterm2 |
| Fonts | font-hack-nerd-font |

---

## Custom Keybindings & Settings

### Zsh

#### Aliases

| Alias | コマンド | 説明 |
|-------|---------|------|
| `vi` | `nvim` | Neovimを起動 |
| `c` | `cursor` | Cursorエディタを起動 |
| `diff` | `colordiff -u` | カラー差分表示 |
| `y` | `yazi` + 環境変数設定 | Yaziを起動（開始ディレクトリを記憶） |
| `ls` | `eza --icons` | モダンなls（アイコン付き） |
| `ll` | `eza -l --git --icons` | 詳細表示 + Git状態 |
| `la` | `eza -la --git --icons` | 隠しファイル含む詳細表示 |
| `lt` | `eza --tree --level=2 --icons` | ツリー表示（2階層） |
| `cat` | `bat --paging=never` | シンタックスハイライト付きcat |
| `catp` | `bat` | ページャー付きbat |

#### Safety Functions

危険な操作を防ぐための保護機能：

| 関数 | 説明 |
|------|------|
| `terraform apply/destroy/import/state/taint/untaint` | 無効化（Terraform Cloud使用を推奨） |
| `git push -f` | 実行前に確認プロンプトを表示 |

#### Sheldon Plugins

| プラグイン | 説明 |
|-----------|------|
| zsh-autosuggestions | コマンド自動補完候補の表示 |
| fast-syntax-highlighting | シンタックスハイライト |

**zsh-autosuggestions キーバインド:**

| キー | 動作 |
|------|------|
| `→` (右矢印) | サジェスト全体を補完 |
| `Ctrl+F` | 単語単位で補完（空白または`/`区切り） |

#### direnv

ディレクトリごとの環境変数管理。`.envrc` ファイルで環境変数を自動設定。

```bash
# プロジェクトで使用
echo 'export API_KEY="xxx"' > .envrc
direnv allow
```

---

### tmux

#### Prefix Key

デフォルトの `C-b` を `C-q` に変更。

#### Keybindings

| キー | 動作 |
|------|------|
| `C-q \|` | ペインを縦分割 |
| `C-q -` | ペインを横分割 |
| `C-q h/j/k/l` | ペイン間をVim風に移動 |
| マウスドラッグ | テキスト選択＆コピー（pbcopy） |

#### Settings

- viモード有効
- マウス操作有効
- ステータスバー: 上部・中央寄せ
- エスケープ待ち時間: 0ms

---

### Git

#### Settings

- デフォルトブランチ: `main`
- エディタ: `nvim`
- push.default: `current`

---

### Neovim (LazyVim)

[LazyVim](https://www.lazyvim.org/) ベースの設定。

#### Options

| オプション | 値 | 説明 |
|-----------|-----|------|
| tabstop/shiftwidth | 2 | インデント幅 |
| relativenumber | true | 相対行番号 |
| scrolloff | 8 | カーソル上下に常に8行表示 |
| clipboard | unnamedplus | システムクリップボードと共有 |
| undofile | true | アンドゥの永続化 |
| wrap | false | 行の折り返しなし |

#### Custom Keymaps

| キー | モード | 動作 |
|------|-------|------|
| `C-s` | n/i | ファイル保存 |
| `<leader>-` | n | 水平分割 |
| `<leader>\|` | n | 垂直分割 |
| `S-h` / `S-l` | n | 前/次のバッファ |
| `<leader>tt` | n | ターミナルを開く |
| `<leader>mp` | n | Markdownプレビュー (Previm) |
| `Esc Esc` | t | ターミナルモードを抜ける |
| `Esc` | n | 検索ハイライトをクリア |

#### LSP / Formatters

初回起動時に自動インストールされる：

**LSP:**
- typescript-language-server
- tailwindcss-language-server
- gopls
- lua-language-server

**Linter / Formatter:**
- eslint_d
- prettierd
- stylua

追加は `:Mason` から。

#### Editor Settings

- neo-tree: 隠しファイル表示、node_modules/.git非表示
- telescope: node_modules, .git/, dist/, build/を除外
- which-key: 遅延300ms

---

### Yazi

#### Custom Keymaps

| キー | 動作 |
|------|------|
| `c r` | 開始ディレクトリからの相対パスをコピー |
| `g s` | 開始ディレクトリに戻る |

`y` 関数で起動すると、開始ディレクトリが `$YAZI_START_DIR` に設定される。

---

### Starship

カスタムプロンプト設定：

- パワーライン風デザイン
- 表示項目: ディレクトリ、Gitブランチ/ステータス、Node.js/Rust/Go/PHP、時刻
- 成功時プロンプト: `><((°>` (魚)
- エラー時プロンプト: `>++°>` (骨)

---

### mise

#### Settings

- 信頼済みパス: `/Volumes/Develop`, `~/dotfiles`
- グローバルNode.js: v24

---

### bat

catの代替。シンタックスハイライト付きでファイルを表示。

#### Settings

| 設定 | 値 |
|------|-----|
| テーマ | Catppuccin Mocha |
| スタイル | 行番号、Git変更、ヘッダー表示 |

テーマ一覧: `bat --list-themes`

---

### macOS Settings

`macos.sh` でシステム設定を自動適用。

```bash
./macos.sh
```

#### 設定内容

| カテゴリ | 設定 |
|---------|------|
| Finder | 隠しファイル表示、拡張子表示、パスバー、ステータスバー |
| Dock | 自動非表示、アニメーション無効、Mission Control高速化、Spaces固定 |
| Keyboard | リピート速度最速、リピート開始最短 |
| Text Input | 自動大文字・スマートダッシュ・スマートクォート・自動修正を無効化 |
| Screenshot | デスクトップ保存、PNG形式、影なし |
| Accessibility | 視差効果を減らす |

---

## Commands

```bash
# セットアップ（全て実行）
./setup.sh

# macOS設定のみ適用
./macos.sh

# Homebrewパッケージ更新
brew bundle --file=~/dotfiles/Brewfile

# Neovim LSP管理
nvim → :Mason

# 設定変更後の反映
source ~/.zshrc

# 特定パッケージのアンリンク
stow -d ~/dotfiles -t "$HOME" -D パッケージ名
```

## Troubleshooting

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
