#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Setting up dotfiles..."

# ----------------------------------------
# Zsh
# ----------------------------------------
echo "📝 Setting up zsh..."

if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  echo "   Backing up existing .zshrc..."
  mv "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
fi

ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "   Created ~/.zshrc.local - Please edit with your tokens"
fi

# ----------------------------------------
# Neovim
# ----------------------------------------
echo "📝 Setting up neovim..."
mkdir -p "$HOME/.config"

if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  echo "   Backing up existing nvim config..."
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
fi

ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# ----------------------------------------
# Yazi
# ----------------------------------------
echo "📝 Setting up yazi..."

if [ -d "$HOME/.config/yazi" ] && [ ! -L "$HOME/.config/yazi" ]; then
  echo "   Backing up existing yazi config..."
  mv "$HOME/.config/yazi" "$HOME/.config/yazi.backup.$(date +%Y%m%d%H%M%S)"
fi

ln -sf "$DOTFILES_DIR/yazi" "$HOME/.config/yazi"

# ----------------------------------------
# Git
# ----------------------------------------
echo "📝 Setting up git..."

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  echo "   Backing up existing .gitconfig..."
  mv "$HOME/.gitconfig" "$HOME/.gitconfig.backup.$(date +%Y%m%d%H%M%S)"
fi

ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

if [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "   Created ~/.gitconfig.local - Please edit with your info"
fi

# ----------------------------------------
# Homebrew (macOS)
# ----------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "🍺 Checking Homebrew..."
  if ! command -v brew &> /dev/null; then
    echo "   Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "   Installing packages from Brewfile..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" || true
fi

# ----------------------------------------
# mise (runtime version manager)
# ----------------------------------------
if command -v mise &> /dev/null; then
  echo "📦 Setting up mise..."
  mise use -g node@24

  echo "📦 Installing global npm packages..."
  npm install -g czg cz-git

  # Load local env for GITHUB_TOKEN
  [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "⚠️  GITHUB_TOKEN not set in ~/.zshrc.local - skipping czg setup"
  else
    echo "🔧 Configuring czg..."
    czg --api-key="$GITHUB_TOKEN" --api-endpoint="https://models.inference.ai.azure.com" --api-model="gpt-4o-mini"
  fi
fi

# ----------------------------------------
# Done
# ----------------------------------------
echo ""
echo "✅ Done!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.zshrc.local with your tokens"
echo "  2. Edit ~/.gitconfig.local with your name/email"
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo "  4. Open nvim to install plugins automatically"
