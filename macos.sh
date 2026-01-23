#!/bin/bash
# ============================================================
#   macOS Settings
#   Run: ./macos.sh
#   Note: Some changes require logout/restart to take effect
# ============================================================

set -e

echo "Applying macOS settings..."

# ----------------------------------------
# Finder
# ----------------------------------------
echo "Configuring Finder..."

# 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# 拡張子を常に表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# ----------------------------------------
# Dock
# ----------------------------------------
echo "Configuring Dock..."

# 自動的に隠す
defaults write com.apple.dock autohide -bool true

# Dock表示の遅延を削除
defaults write com.apple.dock autohide-delay -float 0

# Dock表示/非表示アニメーションを削除
defaults write com.apple.dock autohide-time-modifier -float 0

# アプリ起動時のアニメーションを無効化
defaults write com.apple.dock launchanim -bool false

# Mission Controlのアニメーションを高速化
defaults write com.apple.dock expose-animation-duration -float 0.1

# ワークスペース切り替えアニメーションを無効化
defaults write com.apple.dock workspaces-swoosh-animation-off -bool true

# Spacesの自動並び替えを無効化（配置を固定）
defaults write com.apple.dock mru-spaces -bool false

# 視差効果を減らす（システム全体のアニメーション軽減）
# Note: requires sudo
sudo defaults write com.apple.universalaccess reduceMotion -bool true

# ----------------------------------------
# Keyboard
# ----------------------------------------
echo "Configuring Keyboard..."

# キーリピート速度を最速に
defaults write NSGlobalDomain KeyRepeat -int 1

# キーリピート開始までの時間を最短に
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# ----------------------------------------
# Text Input (自動補正を無効化)
# ----------------------------------------
echo "Configuring Text Input..."

# 自動大文字を無効化
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# スマートダッシュを無効化
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# 自動ピリオド挿入を無効化
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# スマートクォートを無効化
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# 自動スペル修正を無効化
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ----------------------------------------
# ブラウザ
# ----------------------------------------
echo "Configuring Browser..."

# デフォルトブラウザをMicrosoft Edgeに設定
# defaultbrowser コマンドが必要 (brew install defaultbrowser)
if command -v defaultbrowser &> /dev/null; then
  defaultbrowser edgemac
  echo "  Default browser set to Microsoft Edge"
else
  echo "  [SKIP] defaultbrowser command not found. Install with: brew install defaultbrowser"
fi

# Edgeを全Spacesに表示
defaults write com.apple.spaces app-bindings -dict-add "com.microsoft.edgemac" "AllSpaces"

# ----------------------------------------
# Screenshot
# ----------------------------------------
echo "Configuring Screenshot..."

# 保存先をデスクトップに（デフォルト明示）
defaults write com.apple.screencapture location -string "$HOME/Desktop"

# ファイル形式をPNGに
defaults write com.apple.screencapture type -string "png"

# 影を無効化（ウィンドウ撮影時）
defaults write com.apple.screencapture disable-shadow -bool true

# ----------------------------------------
# Apply changes
# ----------------------------------------
echo "Applying changes..."

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo ""
echo "Done!"
echo "Note: Some keyboard settings may require logout to take effect."
