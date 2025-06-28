#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Define the dotfiles directory, assuming the script is run from the repo root.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Define the target for Zsh custom plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# --- Helper Functions for logging with Emojis ---
info() {
  printf "ℹ️  [INFO] %s\n" "$1"
}

success() {
  printf "✅ [SUCCESS] %s\n" "$1"
}

warn() {
  printf "⚠️  [WARNING] %s\n" "$1"
}

error() {
  printf "❌ [ERROR] %s\n" "$1" >&2
  exit 1
}

# --- Installation Functions ---

# Function to install dependencies based on the OS
install_dependencies() {
  info "Installing dependencies..."
  local OS
  OS="$(uname -s)"

  if [[ "$OS" == "Darwin" ]]; then
    info "Detected macOS. Using Homebrew."
    if ! command -v brew &>/dev/null; then
      info "Homebrew not found. Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to PATH for the current script session
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    # Tools from your plugins: bat (for zsh-bat), zoxide, uv, gcloud, tmux
    # Other common dev tools: neovim, fzf
    brew install bat zoxide uv google-cloud-sdk tmux neovim fzf sed ripgrep
  elif [[ "$OS" == "Linux" ]]; then
    info "Detected Linux. Using APT (for Debian/Ubuntu)."
    # Check for sudo
    if ! command -v sudo &>/dev/null; then
      error "sudo command not found. Please install it first."
    fi
    sudo apt-get update
    # Note: 'uv' is not in apt repos, we'll install it separately.
    # 'google-cloud-sdk' is now 'google-cloud-cli' in apt.
    sudo apt-get install -y curl git zsh bat zoxide tmux neovim fzf google-cloud-sdk sed ripgrep

    # On some Ubuntu versions, 'bat' is installed as 'batcat'
    if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
      info "Creating 'bat' symlink for 'batcat'..."
      mkdir -p "$HOME/.local/bin"
      ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    fi

    # Install 'uv' using the official installer since it's not in apt
    if ! command -v uv &>/dev/null; then
      info "Installing uv..."
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
  else
    error "Unsupported OS: $OS. This script supports macOS and Debian-based Linux."
  fi
  success "Dependencies installed."
}

# Function to install Oh My Zsh and custom plugins
install_oh_my_zsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh..."
    # Use --unattended to prevent it from changing the default shell or running zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    info "Oh My Zsh is already installed."
  fi

  info "Installing/updating custom Zsh plugins..."
  # zsh-autosuggestions
  if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
  fi

  # zsh-syntax-highlighting
  if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
  fi
  success "Oh My Zsh and plugins are set up."
}

# Function to create symlinks for dotfiles
create_symlinks() {
  info "Creating symlink for .zshrc..."

  # Backup existing .zshrc if it's a real file and not already a symlink
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    warn "Backing up existing .zshrc to .zshrc.bak"
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  # Create symlink from home directory to the one in the dotfiles repo
  ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  success "Symlinks created."
}

# --- Main Setup ---
main() {
  info "🚀 Starting dotfiles setup..."
  install_dependencies
  install_oh_my_zsh
  create_symlinks
  if [[ "$SHELL" != */zsh ]]; then
    warn "Your default shell is not Zsh. Please change it by running: chsh -s \$(which zsh)"
  fi
  success "🎉 Dotfiles setup complete! Please restart your shell or run 'source ~/.zshrc' to apply changes."
}

main "$@"