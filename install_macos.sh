#!/bin/bash

# --- Pretty-pride: A colorful and fun logger ---
# Because who said installations have to be boring?

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Colors ---
# No, this is not a unicorn's tear, just some good old ANSI codes.
readonly C_RESET='[0m'
readonly C_RED='[0;31m'
readonly C_GREEN='[0;32m'
readonly C_BLUE='[0;34m'
readonly C_YELLOW='[0;33m'
readonly C_CYAN='[0;36m'

# Define the dotfiles directory, assuming the script is run from the repo root.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Logging Functions ---
# Each function is a mini-celebration of your progress.

# Info: For when you need to know what's happening.
info() {
  printf "${C_BLUE}✨ %s${C_RESET}
" "$1"
}

# Success: For when things go right. *confetti*
success() {
  printf "${C_GREEN}🎉 %s${C_RESET}
" "$1"
}

# Warning: For when you should probably pay attention.
warn() {
  printf "${C_YELLOW}🤔 %s${C_RESET}
" "$1"
}

# Error: For when the universe has other plans.
error() {
  printf "${C_RED}💥 Oops! %s${C_RESET}
" "$1" >&2
  exit 1
}

# --- Main Function ---
# The heart of our grand installation adventure.
install_package_brew() {
  local package_name="$1"
  if ! brew list "$package_name" &>/dev/null; then
    info "Installing $package_name... because life's too short for missing dependencies."
    brew install "$package_name" || error "Failed to install $package_name. The package manager is giving us attitude."
    success "$package_name installed. One step closer to digital nirvana!"
  else
    warn "$package_name is already installed. We're ahead of the game!"
  fi
}

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew, the missing package manager for macOS. Hold on tight!"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew. The magic smoke escaped!"
    success "Homebrew installed. You are now a true macOS power user!"
  else
    warn "Homebrew is already installed. You're a seasoned pro!"
  fi
}

install_zsh() {
  info "Setting up Zsh, the shell that makes other shells jealous."
  install_package_brew "zsh"
  install_package_brew "curl" # Ensure curl is available for the zoxide installer
  install_package_brew "git"  # Ensure git is available for cloning zsh plugins

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh not found. Let's get this party started!"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "Oh My Zsh installation failed. The shell gods are displeased."
    success "Oh My Zsh installed. Your shell just got a major upgrade!"
  else
    warn "Oh My Zsh is already installed. You're already living the dream!"
  fi
}

install_oh_my_zsh() {
  install_package_brew "git"

  # Define the target for Zsh custom plugins
  local ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing Oh My Zsh... Because a shell without Oh My Zsh is like a day without sunshine."
    # Use --unattended to prevent it from changing the default shell or running zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "Oh My Zsh installation failed. The shell gods are displeased."
  else
    warn "Oh My Zsh is already installed. You're already living the dream!"
  fi

  info "Installing/updating custom Zsh plugins. This is where the real magic happens!"
  mkdir -p "${ZSH_CUSTOM}/plugins"

  # zsh-syntax-highlighting
  if [ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" || error "Failed to clone zsh-syntax-highlighting."
  fi

  # you-should-use
  if [ ! -d "${ZSH_CUSTOM}/plugins/you-should-use" ]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM}/plugins/you-should-use" || error "Failed to clone you-should-use."
  fi

  if [ ! -d "${ZSH_CUSTOM}/plugins/transient-prompt" ]; then
    git clone https://github.com/imtorrr/zsh-transient-prompt.git "${ZSH_CUSTOM}/plugins/transient-prompt" || error "Failed to clone zsh-transient-prompt"
  fi

  success "Oh My Zsh and plugins are set up. Your shell is now officially supercharged!"
}

create_zshrc_symlink() {
  info "Crafting the perfect .zshrc symlink. It's like magic, but with more command-line."

  # Backup existing .zshrc if it's a real file and not already a symlink
  if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    warn "Found an old .zshrc. Backing it up to .zshrc.bak, just in case you miss the good old days."
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak" || error "Couldn't back up .zshrc. Is it shy?"
  fi

  # Create symlink from home directory to the one in the dotfiles repo
  ln -sf "$DOTFILES_DIR/config/zsh/.zshrc" "$HOME/.zshrc" || error "Failed to create .zshrc symlink. The universe is conspiring against us."
  success ".zshrc symlink created! Your shell is now officially connected to the matrix."
}

install_build_essential() {
  info "Installing Xcode Command Line Tools. Because every great developer needs their tools, right?"
  if ! xcode-select -p &>/dev/null; then
    xcode-select --install || error "Failed to install Xcode Command Line Tools. The App Store is being difficult."
    success "Xcode Command Line Tools installed. Now we're ready to build some serious stuff!"
  else
    warn "Xcode Command Line Tools are already installed. You're ready to rock!"
  fi
}

install_zoxide() {
  info "Installing zoxide, the smart $(cd) command. Because who needs to type full paths anymore?"
  install_package_brew "zoxide"
  success "zoxide installed. Prepare for warp-speed navigation!"
}

install_fzf() {
  info "Installing fzf, the fuzzy finder that'll make you wonder how you lived without it."
  install_package_brew "fzf"
  "$(brew --prefix)/opt/fzf/install" --all
  success "fzf installed. Now go find things, fuzzily!"
}

install_bat() {
  info "Installing bat, the cat clone with wings (and syntax highlighting)!"
  install_package_brew "bat"
  success "bat installed. Your terminal just got a whole lot prettier!"
}

install_ripgrep() {
  info "Installing ripgrep, because searching should be fast and furious!"
  install_package_brew "ripgrep"
  success "ripgrep installed. Your search game just leveled up!"
}

install_fd() {
  info "Installing fd, the user-friendly alternative to find. Because searching should be simple and fast!"
  install_package_brew "fd"
  success "fd installed. Happy hunting!"
}

install_starship() {
  info "Installing Starship, the minimal, blazing-fast, and infinitely customizable prompt. Prepare for liftoff!"
  install_package_brew "starship"
  success "Starship installed. Your prompt just got an upgrade to warp speed!"
}

create_starship_config_symlink() {
  info "Crafting the perfect starship.toml symlink. Your prompt is about to get a serious upgrade!"

  # Create ~/.config if it doesn't exist
  mkdir -p "$HOME/.config" || error "Couldn't create ~/.config directory."

  # Backup existing starship.toml if it's a real file and not already a symlink
  if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    warn "Found an old starship.toml. Backing it up to starship.toml.bak, just in case you miss the good old days."
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak" || error "Couldn't back up starship.toml. Is it shy?"
  fi

  # Create symlink from home directory to the one in the dotfiles repo
  ln -sf "$DOTFILES_DIR/config/starship/starship.toml" "$HOME/.config/starship.toml" || error "Failed to create starship.toml symlink. The universe is conspiring against us."
  success "starship.toml symlink created! Your prompt is now officially connected to the matrix."
}

install_neovim() {
  info "Installing Neovim. Get ready to edit like a pro!"
  install_package_brew "neovim"
  success "Neovim installed. You're already living the life!"
}

install_tree_sitter_cli() {
  info "Installing tree-sitter-cli. Because parsing code is fun!"
  install_package_brew "tree-sitter"
  success "tree-sitter-cli installed. Your code just got a whole lot smarter!"
}

install_lazyvim() {
  info "Setting up LazyVim. Because who has time for manual Neovim configuration?"
  local NVIM_CONFIG_DIR="$HOME/.config/nvim"

  if [ -d "$NVIM_CONFIG_DIR" ]; then
    warn "Existing Neovim configuration found at $NVIM_CONFIG_DIR. LazyVim will not be installed to avoid overwriting it. Please move or delete it if you want to install LazyVim."
  else
    info "Cloning LazyVim starter template. Get ready for a supercharged Neovim experience!"
    git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR" || error "Failed to clone LazyVim starter template."
    success "LazyVim installed. Your Neovim is now officially lazy (and awesome)!"
  fi
}

install_tmux() {
  info "Installing tmux, the terminal multiplexer. Because one terminal is never enough!"
  install_package_brew "tmux"
  success "tmux installed. Get ready to juggle terminals like a pro!"
}

install_tpm() {
  info "Installing TPM (Tmux Plugin Manager). Because managing tmux plugins should be easy!"
  local TPM_DIR="$HOME/.tmux/plugins/tpm"

  if [ -d "$TPM_DIR" ]; then
    warn "TPM is already installed. You're already a tmux power user!"
  else
    info "Cloning TPM repository..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" || error "Failed to clone TPM repository."
    success "TPM installed. Now go find some awesome tmux plugins!"
  fi
}

create_tmux_symlink() {
  info "Crafting the perfect .tmux.conf symlink. Your tmux sessions are about to get a serious upgrade!"

  # Backup existing .tmux.conf if it's a real file and not already a symlink
  if [ -f "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
    warn "Found an old .tmux.conf. Backing it up to .tmux.conf.bak, just in case you miss the good old days."
    mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak" || error "Couldn't back up .tmux.conf. Is it shy?"
  fi

  # Create symlink from home directory to the one in the dotfiles repo
  ln -sf "$DOTFILES_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf" || error "Failed to create .tmux.conf symlink. The universe is conspiring against us."
  success ".tmux.conf symlink created! Your tmux is now officially connected to the matrix."
}

install_uv() {
  info "Installing uv, the extremely fast Python package installer and resolver. Your Python projects are about to get a speed boost!"
  install_package_brew "uv"
  success "uv installed. Your Python workflow just got a whole lot faster!"
}

# --- Main Function ---
# The heart of our grand installation adventure.
main() {
  info "🚀 Starting the magical macOS setup adventure!"
  install_homebrew
  info "Updating Homebrew. Because even magic needs fresh ingredients!"
  brew update || error "Failed to update Homebrew. Is the internet playing hide-and-seek?"

  install_zsh
  install_oh_my_zsh
  create_zshrc_symlink
  install_build_essential
  install_zoxide
  install_fzf
  install_bat
  install_ripgrep
  install_fd
  install_starship
  create_starship_config_symlink
  install_neovim
  install_tree_sitter_cli
  install_lazyvim
  install_tmux
  install_tpm
  create_tmux_symlink
  install_uv

  success "macOS setup complete. Go grab a ☕️, you've earned it!"
}
# --- Let the adventure begin! ---
# This is where we call the main function to kick things off.
main "$@"
