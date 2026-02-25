#!/bin/bash
# lib/common.sh - 共通関数ライブラリ
# sourceされるファイル（直接実行しない）

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ----------------------------------------
# setup_sudo: sudo認証+バックグラウンドkeep-alive+trap
# ----------------------------------------
setup_sudo() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Requesting sudo access (for macOS settings)..."
    sudo -v
    # バックグラウンドでsudoを維持
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done) 2>/dev/null &
    SUDO_PID=$!
    # 終了時にバックグラウンドプロセスをkill（正常終了、エラー、Ctrl+C）
    trap "kill $SUDO_PID 2>/dev/null" EXIT
  fi
}

# ----------------------------------------
# ensure_homebrew: Homebrew未インストール時にインストール
# ----------------------------------------
ensure_homebrew() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    return
  fi

  echo "Checking Homebrew..."
  if ! command -v brew &> /dev/null; then
    echo "  Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo "  Homebrew already installed"
  fi
}

# ----------------------------------------
# ensure_stow: stow未インストール時にインストール
# ----------------------------------------
ensure_stow() {
  echo "Checking stow..."

  if ! command -v stow &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  Installing stow via Homebrew..."
      brew install stow
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      echo "  Installing stow via apt..."
      sudo apt update && sudo apt install -y stow
    fi
  else
    echo "  stow already installed"
  fi
}

# ----------------------------------------
# ensure_tmux: tmux未インストール時にインストール
# ----------------------------------------
ensure_tmux() {
  echo "Checking tmux..."

  if ! command -v tmux &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      echo "  Installing tmux via Homebrew..."
      brew install tmux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      echo "  Installing tmux via apt..."
      sudo apt install -y tmux
    fi
  else
    echo "  tmux already installed"
  fi
}

# ----------------------------------------
# stow_package: 単一パッケージのstow（コンフリクト検知付き）
# ----------------------------------------
stow_package() {
  local pkg=$1

  # Check for conflicts using stow --simulate
  if ! stow -d "$DOTFILES_DIR" -t "$HOME" --simulate "$pkg" 2>/dev/null; then
    echo "  [SKIP] $pkg: existing files found, skipping"
    return
  fi

  stow -d "$DOTFILES_DIR" -t "$HOME" "$pkg"
  echo "  [OK] $pkg"
}

# ----------------------------------------
# stow_packages: 複数パッケージの一括stow
# ----------------------------------------
stow_packages() {
  local packages=("$@")

  echo "Linking dotfiles with stow..."
  for pkg in "${packages[@]}"; do
    stow_package "$pkg"
  done
}

# ----------------------------------------
# setup_iterm2: iTerm2のdefaults write設定（macOSのみ）
# ----------------------------------------
setup_iterm2() {
  if [[ "$OSTYPE" != "darwin"* ]]; then
    return
  fi

  echo "Configuring iTerm2..."
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config/iterm2"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  # Save changes: 0=When Quitting, 1=Manually, 2=Automatically
  defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 2
  echo "  [OK] iTerm2 preferences folder set to ~/.config/iterm2"
}
