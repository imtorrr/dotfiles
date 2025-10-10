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
install_package_apt() {
  local package_name="$1"
  if ! dpkg -s "$package_name" &>/dev/null; then
    info "Installing $package_name... because life's too short for missing dependencies."
    apt-get install -y "$package_name" || error "Failed to install $package_name. The package manager is giving us attitude."
    success "$package_name installed. One step closer to digital nirvana!"
  else
    warn "$package_name is already installed. We're ahead of the game!"
  fi
}

install_zsh() {
  info "Setting up Zsh, the shell that makes other shells jealous."
  install_package_apt "zsh"
  install_package_apt "curl" # Ensure curl is available for the zoxide installer
  install_package_apt "git"  # Ensure git is available for cloning zsh plugins

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Oh My Zsh not found. Let's get this party started!"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || error "Oh My Zsh installation failed. The shell gods are displeased."
    success "Oh My Zsh installed. Your shell just got a major upgrade!"
  else
    warn "Oh My Zsh is already installed. You're already living the dream!"
  fi
}

install_oh_my_zsh() {
  install_package_apt "git"

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
  info "Installing build-essential. Because every great developer needs their tools, right?"
  install_package_apt "build-essential"
  success "build-essential installed. Now we're ready to build some serious stuff!"
}

install_clipboard_tools() {
  info "Installing xclip and xsel for clipboard magic. Because copying and pasting should be effortless!"
  install_package_apt "xclip"
  install_package_apt "xsel"
  success "Clipboard tools installed. Your copy-paste game is strong!"
}

install_zoxide() {
  info "Installing zoxide, the smart $(cd) command. Because who needs to type full paths anymore?"
  install_package_apt "curl" # Ensure curl is available for the zoxide installer

  if ! command -v zoxide &>/dev/null; then
    info "Running zoxide's official installer. It's like magic, but with more shell scripting."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || error "Zoxide installation failed. Did the internet hiccup?"
    success "zoxide installed. Prepare for warp-speed navigation!"
  else
    warn "zoxide is already installed. You're already navigating like a pro!"
  fi
}

install_fzf() {
  info "Installing fzf, the fuzzy finder that'll make you wonder how you lived without it."
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
  $HOME/.fzf/install --all
  success "fzf installed. Now go find things, fuzzily!"
}

install_bat() {
  info "Installing bat, the cat clone with wings (and syntax highlighting)!"
  install_package_apt "bat"

  # On some Ubuntu versions, 'bat' is installed as 'batcat'
  if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
    info "Creating 'bat' symlink for 'batcat'. Because consistency is key!"
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" || error "Failed to create batcat symlink. The symlink fairy is on strike."
  fi
  success "bat installed. Your terminal just got a whole lot prettier!"
}

install_ripgrep() {
  info "Installing ripgrep, because searching should be fast and furious!"
  install_package_apt "ripgrep"
  success "ripgrep installed. Your search game just leveled up!"
}

install_fd() {
  info "Installing fd, the user-friendly alternative to find. Because searching should be simple and fast!"
  install_package_apt "fd-find"
  # Create a symlink for 'fd' if the executable is 'fdfind'
  if ! command -v fd &>/dev/null && command -v fdfind &>/dev/null; then
    info "Creating 'fd' symlink for 'fdfind'."
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" || error "Failed to create fd symlink."
  fi
  success "fd installed. Happy hunting!"
}

install_starship() {
  info "Installing Starship, the minimal, blazing-fast, and infinitely customizable prompt. Prepare for liftoff!"
  install_package_apt "curl" # Ensure curl is available for the starship installer

  if ! command -v starship &>/dev/null; then
    info "Running Starship's official installer. To infinity and beyond!"
    curl -sS https://starship.rs/install.sh | sh -s -- -y || error "Starship installation failed. Houston, we have a problem."
    success "Starship installed. Your prompt just got an upgrade to warp speed!"
  else
    warn "Starship is already installed. You're already cruising the cosmos!"
  fi
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
  info "Installing Neovim from the official GitHub releases. Getting the bleeding edge!"
  install_package_apt "curl" # Ensure curl is available

  if ! command -v nvim &>/dev/null; then
    info "Downloading Neovim pre-built archive..."
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz || error "Failed to download Neovim archive."

    info "Extracting Neovim to /opt..."
    rm -rf /opt/nvim-linux-x86_64 || warn "Could not remove existing /opt/nvim-linux-x86_64. Continuing anyway."
    tar -C /opt -xzf nvim-linux-x86_64.tar.gz || error "Failed to extract Neovim archive."

    info "Cleaning up downloaded archive..."
    rm nvim-linux-x86_64.tar.gz || warn "Could not remove Neovim archive."

    success "Neovim installed to /opt/nvim-linux-x86_64. Get ready to edit like a pro!"
  else
    warn "Neovim is already installed. You're already living the $(nvim) life!"
  fi
}

install_nerd_font_jetbrains_mono() {
  install_package_apt "unzip"

  info "Installing JetBrainsMono Nerd Font. Because your terminal deserves to look amazing!"
  local FONT_DIR="$HOME/.local/share/fonts"
  local FONT_ZIP="JetBrainsMono.zip"
  local FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/JetBrainsMono.zip"

  mkdir -p "$FONT_DIR" || error "Failed to create font directory."

  info "Downloading JetBrainsMono Nerd Font..."
  curl -LO "$FONT_URL" || error "Failed to download JetBrainsMono Nerd Font."

  info "Unzipping fonts to $FONT_DIR..."
  unzip -o "$FONT_ZIP" -d "$FONT_DIR" || error "Failed to unzip JetBrainsMono Nerd Font."

  info "Cleaning up downloaded zip file..."
  rm "$FONT_ZIP" || warn "Could not remove font zip file."

  info "Updating font cache. Making sure your system knows about the new cool kid in town!"
  fc-cache -fv || error "Failed to update font cache."

  success "JetBrainsMono Nerd Font installed. Your terminal just got a serious style upgrade!"
}

install_tree_sitter_cli() {
  info "Installing tree-sitter-cli. Because parsing code is fun!"
  install_package_apt "curl" # Ensure curl is available

  if ! command -v tree-sitter &>/dev/null; then
    info "Downloading tree-sitter-cli pre-built binary..."
    local TS_VERSION="0.20.8" # Latest stable version as of now
    local TS_URL="https://github.com/tree-sitter/tree-sitter/releases/download/v${TS_VERSION}/tree-sitter-linux-x64.gz"
    local TS_BIN="tree-sitter"
    local TS_PATH="$HOME/.local/bin"

    mkdir -p "$TS_PATH" || error "Failed to create $TS_PATH."

    curl -LO "$TS_URL" || error "Failed to download tree-sitter-cli."
    gunzip "tree-sitter-linux-x64.gz" || error "Failed to decompress tree-sitter-cli."
    mv "tree-sitter-linux-x64" "$TS_PATH/$TS_BIN" || error "Failed to move tree-sitter-cli binary."
    chmod +x "$TS_PATH/$TS_BIN" || error "Failed to make tree-sitter-cli executable."

    success "tree-sitter-cli installed. Your code just got a whole lot smarter!"
  else
    warn "tree-sitter-cli is already installed. You're already a parsing wizard!"
  fi
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
  install_package_apt "tmux"
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
  install_package_apt "curl" # Ensure curl is available

  if ! command -v uv &>/dev/null; then
    info "Running uv's official installer. Prepare for lightning-fast Python package management!"
    curl -LsSf https://astral.sh/uv/install.sh | sh || error "uv installation failed. The Python gods are frowning."
    success "uv installed. Your Python workflow just got a whole lot faster!"
  else
    warn "uv is already installed. You're already managing Python packages at warp speed!"
  fi
}

install_docker() {
  info "Installing Docker. Get ready to containerize all the things!"

  if ! command -v docker &>/dev/null; then
    # Uninstall old versions
    info "Uninstalling any conflicting old Docker versions..."
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove -y $pkg; done

    # Add Docker's official GPG key:
    info "Adding Docker's official GPG key..."
    sudo apt-get update || error "Failed to update apt packages."
    sudo apt-get install -y ca-certificates curl gnupg || error "Failed to install ca-certificates, curl, or gnupg."
    sudo install -m 0755 -d /etc/apt/keyrings || error "Failed to create /etc/apt/keyrings directory."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg || error "Failed to add Docker GPG key."
    sudo chmod a+r /etc/apt/keyrings/docker.gpg || error "Failed to set permissions for Docker GPG key."

    # Add the repository to Apt sources:
    info "Adding Docker repository to Apt sources..."
    echo \
      "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null || error "Failed to add Docker repository."
    sudo apt-get update || error "Failed to update apt packages after adding Docker repo."

    # Install Docker packages
    info "Installing Docker Engine, CLI, and Containerd..."
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || error "Failed to install Docker packages."

    # Add current user to docker group
    info "Adding current user to the docker group. You might need to log out and back in for this to take effect."
    sudo usermod -aG docker $USER || error "Failed to add user to docker group."

    # Enable and start Docker service
    info "Enabling and starting Docker service..."
    sudo systemctl enable docker.service || error "Failed to enable Docker service."
    sudo systemctl enable containerd.service || error "Failed to enable containerd service."
    sudo systemctl start docker.service || error "Failed to start Docker service."
    sudo systemctl start containerd.service || error "Failed to start containerd service."

    success "Docker installed. Your system is now a container powerhouse!"
  else
    warn "Docker is already installed. You're already sailing the container seas!"
  fi
}

# --- Main Function ---
# The heart of our grand installation adventure.
main() {
  info "🚀 Starting the magical Linux setup adventure!"
  info "Updating package lists. Because even magic needs fresh ingredients!"
  apt-get update || error "Failed to update apt packages. Is the internet playing hide-and-seek?"

  install_zsh
  install_oh_my_zsh
  create_zshrc_symlink
  install_build_essential
  install_clipboard_tools
  install_zoxide
  install_fzf
  install_bat
  install_ripgrep
  install_fd
  install_starship
  create_starship_config_symlink
  install_neovim
  # install_nerd_font_jetbrains_mono
  install_tree_sitter_cli
  install_lazyvim
  install_tmux
  install_tpm
  create_tmux_symlink
  install_uv
  # install_docker

  success "Linux setup complete. Go grab a ☕️, you've earned it!"
}
# --- Let the adventure begin! ---
# This is where we call the main function to kick things off.
main "$@"
