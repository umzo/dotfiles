#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Setting up dotfiles..."

# ----------------------------------------
# Install stow
# ----------------------------------------
echo "Checking stow..."

if ! command -v stow &> /dev/null; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
      echo "  Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "  Installing stow via Homebrew..."
    brew install stow
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "  Installing stow via apt..."
    sudo apt update && sudo apt install -y stow
  fi
fi

# ----------------------------------------
# Install tmux
# ----------------------------------------
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

# ----------------------------------------
# Stow packages
# ----------------------------------------
PACKAGES=(zsh git nvim yazi mise tmux)

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

echo "Linking dotfiles with stow..."
for pkg in "${PACKAGES[@]}"; do
  stow_package "$pkg"
done

# ----------------------------------------
# Local config files (not managed by stow)
# ----------------------------------------
echo "Setting up local config files..."

if [ ! -f "$HOME/.zshrc.local" ]; then
  cp "$DOTFILES_DIR/zsh/.zshrc.local.example" "$HOME/.zshrc.local"
  echo "  Created ~/.zshrc.local - Please edit with your tokens"
else
  echo "  [SKIP] ~/.zshrc.local already exists"
fi

if [ ! -f "$HOME/.gitconfig.local" ]; then
  cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$HOME/.gitconfig.local"
  echo "  Created ~/.gitconfig.local - Please edit with your info"
else
  echo "  [SKIP] ~/.gitconfig.local already exists"
fi

# ----------------------------------------
# Homebrew (macOS)
# ----------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing Homebrew packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile" || true
  brew install satococoa/tap/wtp || true
fi

# ----------------------------------------
# mise (runtime version manager)
# ----------------------------------------
if command -v mise &> /dev/null; then
  echo "Setting up mise..."
  mise trust "$DOTFILES_DIR/mise/.config/mise/config.toml"
  mise use -g node@24

  echo "Installing global npm packages..."
  mise exec -- npm install -g czg cz-git

  # Load local env for GITHUB_TOKEN
  [[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

  if [ -z "$GITHUB_TOKEN" ]; then
    echo "  GITHUB_TOKEN not set in ~/.zshrc.local - skipping czg setup"
  else
    echo "Configuring czg..."
    mise exec -- czg --api-key="$GITHUB_TOKEN" --api-endpoint="https://models.inference.ai.azure.com" --api-model="gpt-4o-mini"
  fi
fi

# ----------------------------------------
# Done
# ----------------------------------------
echo ""
echo "Done!"
echo ""
echo "Next steps:"
echo "  1. Edit ~/.zshrc.local with your tokens"
echo "  2. Edit ~/.gitconfig.local with your name/email"
echo "  3. Restart your terminal or run: source ~/.zshrc"
echo "  4. Open nvim to install plugins automatically"
