#!/bin/bash
set -e

source "$(cd "$(dirname "$0")" && pwd)/lib/common.sh"

echo "Setting up dev environment (iterm2 + tmux + lazygit + yazi)..."

# ----------------------------------------
# Sudo認証（最初に1回だけ）
# ----------------------------------------
setup_sudo

# ----------------------------------------
# Install prerequisites
# ----------------------------------------
ensure_homebrew
ensure_stow
ensure_tmux

# ----------------------------------------
# Homebrew packages (macOS)
# ----------------------------------------
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Installing dev packages..."
  brew bundle --file="$DOTFILES_DIR/Brewfile.dev" || true
fi

# ----------------------------------------
# Stow packages
# ----------------------------------------
DEV_PACKAGES=(iterm2 tmux lazygit yazi bin bat starship mise)

stow_packages "${DEV_PACKAGES[@]}"

# ----------------------------------------
# iTerm2 (macOS)
# ----------------------------------------
setup_iterm2

# ----------------------------------------
# mise (runtime version manager)
# ----------------------------------------
if command -v mise &> /dev/null; then
  echo "Setting up mise..."
  mise trust "$DOTFILES_DIR/mise/.config/mise/config.toml"
  mise use -g node@24

  echo "Installing global npm packages..."
  mise exec -- npm install -g czg cz-git difit

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
echo "  1. Restart your terminal or open iTerm2"
echo "  2. Start a dev session: dev-tmux <session-name> [directory]"
echo "  3. Use lazygit for git operations, yazi for file navigation"
