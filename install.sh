#!/usr/bin/env zsh
# Simple cross-platform dotfiles installer
# Supports: macOS, Linux (Debian/Ubuntu, Arch), and WSL
# Usage: ./install.sh [OPTIONS]
#
# Options:
#   -y, --yes    Auto-accept all prompts (non-interactive mode)
#   -h, --help   Show this help message
#
# Note: Uses zsh for associative array support (bash 3.2 on macOS is too old)

set -e

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OS_TYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
IS_WSL=false
PKG_MANAGER=""
AUTO_YES=false

# Parse command line arguments
for arg in "$@"; do
    case $arg in
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes    Auto-accept all prompts (non-interactive mode)"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Run '$0 --help' for usage information"
            exit 1
            ;;
    esac
done

# Check if we're in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    IS_WSL=true
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Package lists (customize these!)
BREW_PACKAGES=(
    "git"
    "neovim"
    "tmux"
    "zsh"
    "fzf"
    "ripgrep"
    "bat"
    "eza"
    "fd"
    "zoxide"
    "starship"
    "uv"
    "lazygit"
    "python@3"
)

APT_PACKAGES=(
    "git"
    "tmux"
    "zsh"
    "fzf"
    "ripgrep"
    "bat"
    "curl"
    "wget"
    "unzip"
    "build-essential"
    "zoxide"
    "starship"
    "eza"
    "fd-find"
    "lazygit"
    "python3"
    "python3-pip"
    "python3-venv"
)

PACMAN_PACKAGES=(
    "git"
    "neovim"
    "tmux"
    "zsh"
    "fzf"
    "ripgrep"
    "bat"
    "curl"
    "wget"
    "unzip"
    "base-devel"
    "zoxide"
    "starship"
    "eza"
    "fd"
    "lazygit"
    "python"
    "python-pip"
)

# Config symlinks (source:destination)
# Add your own config files here!
typeset -A CONFIGS
CONFIGS=(
    "config/zsh/zshrc" "$HOME/.zshrc"
    "config/zsh/aliases" "$HOME/.config/zsh/.aliases"
    "config/nvim" "$HOME/.config/nvim"
    "config/tmux/tmux.conf" "$HOME/.tmux.conf"
    "config/starship/starship.toml" "$HOME/.config/starship.toml"
)

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

print_header() {
    echo ""
    echo -e "${BLUE}==>${NC} ${1}"
}

print_success() {
    echo -e "${GREEN}✓${NC} ${1}"
}

print_error() {
    echo -e "${RED}✗${NC} ${1}" >&2
}

print_warning() {
    echo -e "${YELLOW}!${NC} ${1}"
}

ask_yes_no() {
    local prompt="$1"

    # Auto-accept if -y flag was passed
    if [[ "$AUTO_YES" == true ]]; then
        echo -e "${YELLOW}?${NC} ${prompt} (y/n): ${GREEN}y${NC} (auto-accepted)"
        return 0
    fi

    while true; do
        read "response?$(echo -e "${YELLOW}?${NC} ${prompt} (y/n): ")"
        case "$response" in
            [Yy]*) return 0 ;;
            [Nn]*) return 1 ;;
            *) echo "Please answer y or n" ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Main Functions
# -----------------------------------------------------------------------------

detect_system() {
    print_header "Detecting system"

    echo "Operating System: $OS_TYPE"

    if [[ "$IS_WSL" == true ]]; then
        echo "Environment: WSL 2"
    fi

    # Detect package manager on Linux
    if [[ "$OS_TYPE" == "linux" ]]; then
        if command -v apt &>/dev/null; then
            PKG_MANAGER="apt"
        elif command -v pacman &>/dev/null; then
            PKG_MANAGER="pacman"
        else
            print_error "No supported package manager found"
            exit 1
        fi
        echo "Package Manager: $PKG_MANAGER"
    elif [[ "$OS_TYPE" == "darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            print_error "Homebrew not found!"
            echo "Install it from: https://brew.sh"
            exit 1
        fi
        echo "Package Manager: brew"
    else
        print_error "Unsupported OS: $OS_TYPE"
        exit 1
    fi

    print_success "System detected successfully"
}

install_neovim() {
    print_header "Neovim Installation"

    local nvim_version="0.11.6"

    if command -v nvim &>/dev/null; then
        local current_version
        current_version=$(nvim --version | head -1 | awk '{print $2}' | sed 's/v//')

        if [[ "$current_version" == "$nvim_version" ]]; then
            print_success "Neovim $current_version (latest version already installed)"
            return
        else
            echo "Current Neovim version: $current_version"
            if ! ask_yes_no "Update Neovim to version $nvim_version?"; then
                print_warning "Keeping current Neovim version"
                return
            fi
        fi
    else
        if ! ask_yes_no "Install Neovim $nvim_version?"; then
            print_warning "Skipping Neovim installation"
            return
        fi
    fi

    echo ""

    if [[ "$OS_TYPE" == "darwin" ]]; then
        # macOS with Homebrew
        if brew list neovim &>/dev/null; then
            echo "Upgrading Neovim via Homebrew..."
            brew upgrade neovim
        else
            echo "Installing Neovim via Homebrew..."
            brew install neovim
        fi
        print_success "Neovim installed via Homebrew"

    elif [[ "$OS_TYPE" == "linux" ]]; then
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            # Debian/Ubuntu - Install from official GitHub release
            echo "Installing Neovim $nvim_version from GitHub releases..."

            local temp_dir="/tmp/nvim-install"
            mkdir -p "$temp_dir"

            # Download the .deb package
            local deb_url="https://github.com/neovim/neovim/releases/download/v${nvim_version}/nvim-linux-x86_64.tar.gz"

            echo "Downloading Neovim $nvim_version..."
            if curl -fLo "$temp_dir/nvim-linux-x86_64.tar.gz" "$deb_url"; then
                echo "Extracting Neovim..."
                tar -xzf "$temp_dir/nvim-linux-x86_64.tar.gz" -C "$temp_dir"

                # Remove old installation if exists
                sudo rm -rf /opt/nvim

                # Move to /opt
                sudo mv "$temp_dir/nvim-linux64" /opt/nvim

                # Create symlink
                sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

                rm -rf "$temp_dir"
                print_success "Neovim $nvim_version installed from GitHub"
            else
                print_error "Failed to download Neovim"
                rm -rf "$temp_dir"
                return 1
            fi

        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            # Arch Linux - use package manager (usually has latest version)
            echo "Installing Neovim via pacman..."
            sudo pacman -S --needed --noconfirm neovim
            print_success "Neovim installed via pacman"
        fi
    fi

    # Verify installation
    if command -v nvim &>/dev/null; then
        local installed_version
        installed_version=$(nvim --version | head -1 | awk '{print $2}')
        print_success "Neovim $installed_version is ready"
    else
        print_error "Neovim installation verification failed"
        return 1
    fi
}

install_packages() {
    print_header "Package Installation"

    if ! ask_yes_no "Install development packages?"; then
        print_warning "Skipping package installation"
        return
    fi

    echo ""
    echo "Installing packages..."

    if [[ "$OS_TYPE" == "darwin" ]]; then
        # macOS with Homebrew
        for pkg in "${BREW_PACKAGES[@]}"; do
            if brew list "$pkg" &>/dev/null; then
                print_success "$pkg (already installed)"
            else
                echo "Installing $pkg..."
                brew install "$pkg" && print_success "$pkg installed"
            fi
        done

    elif [[ "$OS_TYPE" == "linux" ]]; then
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            # Debian/Ubuntu
            echo "Updating package list..."
            sudo apt update

            for pkg in "${APT_PACKAGES[@]}"; do
                if dpkg -l | grep -q "^ii  $pkg "; then
                    print_success "$pkg (already installed)"
                else
                    echo "Installing $pkg..."
                    sudo apt install -y "$pkg" && print_success "$pkg installed"
                fi
            done

        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            # Arch Linux
            echo "Installing packages with pacman..."
            sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
            print_success "All packages installed"
        fi
    fi

    print_success "Package installation complete!"
}

create_directories() {
    print_header "Creating directories"

    local dirs=(
        "$HOME/.config"
        "$HOME/.config/zsh"
        "$HOME/.local/bin"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            print_success "Created: $dir"
        fi
    done
}

backup_file() {
    local file="$1"
    if [[ -e "$file" ]] && [[ ! -L "$file" ]]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        print_warning "Backed up: $(basename "$file") → $(basename "$backup")"
    fi
}

create_symlinks() {
    print_header "Creating symlinks"

    if ! ask_yes_no "Create symlinks for config files?"; then
        print_warning "Skipping symlink creation"
        return
    fi

    echo ""

    for source in ${(k)CONFIGS}; do
        local src="$DOTFILES_DIR/$source"
        local dest="${CONFIGS[$source]}"

        # Check if source exists
        if [[ ! -e "$src" ]]; then
            print_warning "Source not found: $source (skipping)"
            continue
        fi

        # Backup existing file
        backup_file "$dest"

        # Remove existing file/directory/symlink if it still exists
        rm -rf "$dest" 2>/dev/null || true

        # Create parent directory
        mkdir -p "$(dirname "$dest")"

        # Create symlink
        ln -sf "$src" "$dest"
        print_success "Linked: $source → $dest"
    done

    print_success "Symlinks created successfully!"
}

install_oh_my_zsh() {
    print_header "Oh My Zsh Installation"

    if ! command -v zsh &>/dev/null; then
        print_warning "Zsh not installed, skipping Oh My Zsh installation"
        return
    fi

    local omz_dir="$HOME/.oh-my-zsh"

    if [[ -d "$omz_dir" ]]; then
        print_success "Oh My Zsh already installed"
    else
        if ask_yes_no "Install Oh My Zsh?"; then
            echo "Installing Oh My Zsh..."
            # Use unattended installation
            RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
            print_success "Oh My Zsh installed"
        else
            print_warning "Skipping Oh My Zsh installation"
            return
        fi
    fi
}

install_zsh_plugins() {
    print_header "Zsh Plugins Installation"

    local omz_custom="$HOME/.oh-my-zsh/custom/plugins"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        print_warning "Oh My Zsh not installed, skipping plugin installation"
        return
    fi

    if ! ask_yes_no "Install custom Zsh plugins?"; then
        print_warning "Skipping Zsh plugin installation"
        return
    fi

    echo ""

    # fzf-tab
    if [[ -d "$omz_custom/fzf-tab" ]]; then
        print_success "fzf-tab already installed"
    else
        echo "Installing fzf-tab..."
        git clone https://github.com/Aloxaf/fzf-tab "$omz_custom/fzf-tab"
        print_success "fzf-tab installed"
    fi

    # you-should-use
    if [[ -d "$omz_custom/you-should-use" ]]; then
        print_success "you-should-use already installed"
    else
        echo "Installing you-should-use..."
        git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$omz_custom/you-should-use"
        print_success "you-should-use installed"
    fi

    # fast-syntax-highlighting
    if [[ -d "$omz_custom/fast-syntax-highlighting" ]]; then
        print_success "fast-syntax-highlighting already installed"
    else
        echo "Installing fast-syntax-highlighting..."
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git "$omz_custom/fast-syntax-highlighting"
        print_success "fast-syntax-highlighting installed"
    fi

    print_success "Zsh plugins installation complete!"
}

setup_zsh() {
    print_header "Zsh Setup"

    if ! command -v zsh &>/dev/null; then
        print_warning "Zsh not installed, skipping shell setup"
        return
    fi

    local current_shell="$(basename "$SHELL")"

    if [[ "$current_shell" != "zsh" ]]; then
        if ask_yes_no "Set Zsh as your default shell?"; then
            local zsh_path="$(which zsh)"

            # Add to valid shells if needed
            if ! grep -q "$zsh_path" /etc/shells 2>/dev/null; then
                echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
            fi

            chsh -s "$zsh_path"
            print_success "Shell changed to Zsh (restart terminal to apply)"
        fi
    else
        print_success "Zsh is already your default shell"
    fi
}

setup_git() {
    print_header "Git Configuration"

    local git_name="$(git config --global user.name 2>/dev/null)"
    local git_email="$(git config --global user.email 2>/dev/null)"

    if [[ -z "$git_name" ]]; then
        read "git_name?Enter your name for Git: "
        git config --global user.name "$git_name"
        print_success "Git name set: $git_name"
    else
        print_success "Git name: $git_name"
    fi

    if [[ -z "$git_email" ]]; then
        read "git_email?Enter your email for Git: "
        git config --global user.email "$git_email"
        print_success "Git email set: $git_email"
    else
        print_success "Git email: $git_email"
    fi
}

install_docker() {
    print_header "Docker"

    if command -v docker &>/dev/null; then
        print_success "Docker already installed"
        return
    fi

    if ! ask_yes_no "Install Docker?"; then
        print_warning "Skipping Docker installation"
        return
    fi

    if [[ "$OS_TYPE" == "darwin" ]]; then
        # macOS - install Docker Desktop via Homebrew
        echo "Installing Docker Desktop..."
        if brew list --cask docker &>/dev/null; then
            print_success "Docker Desktop already installed"
        else
            brew install --cask docker
            print_success "Docker Desktop installed"
            echo "  Launch Docker Desktop from Applications to complete setup"
        fi

    elif [[ "$OS_TYPE" == "linux" ]]; then
        if [[ "$PKG_MANAGER" == "apt" ]]; then
            # Debian/Ubuntu
            echo "Installing Docker Engine..."

            # Remove old versions
            sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

            # Install prerequisites
            sudo apt-get update
            sudo apt-get install -y ca-certificates curl gnupg lsb-release

            # Add Docker's official GPG key
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg

            # Set up the repository
            echo \
              "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
              $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
              sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

            # Install Docker Engine
            sudo apt-get update
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

            print_success "Docker Engine installed"

        elif [[ "$PKG_MANAGER" == "pacman" ]]; then
            # Arch Linux
            echo "Installing Docker..."
            sudo pacman -S --needed --noconfirm docker docker-compose

            # Enable and start Docker service
            sudo systemctl enable docker.service
            sudo systemctl start docker.service

            print_success "Docker installed"
        fi

        # Add user to docker group
        if ! groups | grep -q docker; then
            echo "Adding $USER to docker group..."
            sudo usermod -aG docker "$USER"
            print_success "User added to docker group"
            echo "  Log out and back in for group changes to take effect"
        fi
    fi
}

install_nerd_fonts() {
    print_header "Nerd Fonts"

    if ! ask_yes_no "Install Nerd Fonts?"; then
        print_warning "Skipping Nerd Fonts installation"
        return
    fi

    # Default font to install (you can customize this)
    local FONT_NAME="JetBrainsMono"

    if [[ "$OS_TYPE" == "darwin" ]]; then
        # macOS - Check if font files already exist
        if ls "$HOME/Library/Fonts/"*"JetBrainsMono"*"NerdFont"* &>/dev/null || \
           ls /Library/Fonts/*"JetBrainsMono"*"NerdFont"* &>/dev/null; then
            print_success "JetBrainsMono Nerd Font already installed (font files found)"
        elif brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
            print_success "JetBrainsMono Nerd Font already installed (via Homebrew)"
        else
            echo "Installing ${FONT_NAME} Nerd Font via Homebrew..."
            brew install --cask font-jetbrains-mono-nerd-font
            print_success "JetBrainsMono Nerd Font installed"
        fi

    elif [[ "$OS_TYPE" == "linux" ]]; then
        # Linux - manual download and install
        local fonts_dir="$HOME/.local/share/fonts/NerdFonts"
        local temp_dir="/tmp/nerd-fonts"

        # Check if font already exists
        if ls "$fonts_dir/"*"${FONT_NAME}"* &>/dev/null || \
           fc-list | grep -qi "${FONT_NAME}.*Nerd"; then
            print_success "${FONT_NAME} Nerd Font already installed"
        else
            mkdir -p "$fonts_dir"
            mkdir -p "$temp_dir"

            echo "Downloading ${FONT_NAME} Nerd Font..."
            local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${FONT_NAME}.zip"

            if curl -fLo "$temp_dir/${FONT_NAME}.zip" "$font_url"; then
                echo "Extracting fonts..."
                unzip -o -q "$temp_dir/${FONT_NAME}.zip" -d "$fonts_dir"
                rm -rf "$temp_dir"

                echo "Updating font cache..."
                fc-cache -fv "$fonts_dir" >/dev/null 2>&1

                print_success "${FONT_NAME} Nerd Font installed"
            else
                print_error "Failed to download ${FONT_NAME} Nerd Font"
                rm -rf "$temp_dir"
                return 1
            fi
        fi
    fi

    echo "  Remember to set your terminal to use a Nerd Font!"
}

install_tmux_tpm() {
    print_header "Tmux Plugin Manager"

    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        print_success "TPM already installed"
    else
        if ask_yes_no "Install Tmux Plugin Manager?"; then
            git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
            print_success "TPM installed"
            echo "  Open tmux and press: prefix + I (capital i) to install plugins"
        fi
    fi
}

install_uv() {
    print_header "UV - Fast Python Package Manager"

    if command -v uv &>/dev/null; then
        local uv_version="$(uv --version 2>/dev/null | awk '{print $2}')"
        print_success "UV already installed (version $uv_version)"
        return
    fi

    if ! ask_yes_no "Install UV for Python development?"; then
        print_warning "Skipping UV installation"
        return
    fi

    if [[ "$OS_TYPE" == "darwin" ]]; then
        # On macOS, it should be installed via Homebrew (in package list)
        if command -v brew &>/dev/null; then
            echo "Installing UV via Homebrew..."
            brew install uv && print_success "UV installed via Homebrew"
        fi
    else
        # On Linux, use the official installer
        echo "Installing UV via official installer..."
        curl -LsSf https://astral.sh/uv/install.sh | sh

        # Add to PATH for current session
        export PATH="$HOME/.local/bin:$PATH"

        if command -v uv &>/dev/null; then
            print_success "UV installed successfully"
        else
            print_error "UV installation failed"
            return 1
        fi
    fi

    echo ""
    echo "UV features:"
    echo "  • 10-100x faster than pip"
    echo "  • Drop-in replacement for pip, pip-tools, and virtualenv"
    echo "  • Compatible with existing Python projects"
    echo ""
    echo "Usage examples:"
    echo "  uv pip install <package>     # Install packages"
    echo "  uv venv                       # Create virtual environment"
    echo "  uv pip compile requirements.in -o requirements.txt"
    echo ""
}

check_lazyvim_prereqs() {
    print_header "Checking LazyVim Prerequisites"

    local all_good=true

    # Check Neovim
    if command -v nvim &>/dev/null; then
        local nvim_version
        nvim_version=$(nvim --version | head -1 | awk '{print $2}' | sed 's/v//')
        if printf '%s\n%s\n' "0.9.0" "$nvim_version" | sort -V -C; then
            print_success "Neovim $nvim_version (>= 0.9.0 required)"
        else
            print_error "Neovim $nvim_version (>= 0.9.0 required)"
            all_good=false
        fi
    else
        print_error "Neovim not found"
        all_good=false
    fi

    # Check Git
    if command -v git &>/dev/null; then
        local git_version
        git_version=$(git --version | awk '{print $3}')
        if printf '%s\n%s\n' "2.19.0" "$git_version" | sort -V -C; then
            print_success "Git $git_version (>= 2.19.0 required)"
        else
            print_warning "Git $git_version (>= 2.19.0 recommended)"
        fi
    else
        print_error "Git not found"
        all_good=false
    fi

    # Check C compiler (for treesitter)
    if [[ "$OS_TYPE" == "darwin" ]]; then
        if command -v clang &>/dev/null; then
            print_success "C compiler (clang) found"
        else
            print_warning "C compiler not found - install Xcode Command Line Tools"
            echo "  Run: xcode-select --install"
            all_good=false
        fi
    else
        if command -v gcc &>/dev/null || command -v clang &>/dev/null; then
            print_success "C compiler found"
        else
            print_warning "C compiler not found (build-essential package)"
            all_good=false
        fi
    fi

    # Check optional but recommended tools
    if command -v rg &>/dev/null; then
        print_success "ripgrep found (for Telescope live grep)"
    else
        print_warning "ripgrep not found (recommended for Telescope)"
    fi

    if command -v fd &>/dev/null; then
        print_success "fd found (for Telescope file finder)"
    else
        print_warning "fd not found (recommended for Telescope)"
    fi

    if command -v lazygit &>/dev/null; then
        print_success "lazygit found (for git integration)"
    else
        print_warning "lazygit not found (recommended for git UI)"
    fi

    echo ""
    if [[ "$all_good" == true ]]; then
        print_success "All LazyVim prerequisites are installed!"
        echo ""
        echo "Your LazyVim config is at: $DOTFILES_DIR/config/nvim"
        echo ""
        echo "Next steps:"
        echo "  1. Symlink will be created during config setup"
        echo "  2. Run: nvim"
        echo "  3. Wait for plugins to install automatically"
        echo "  4. Restart Neovim"
        echo "  5. Run: :checkhealth"
    else
        print_warning "Some prerequisites are missing - install them first"
    fi
}

show_next_steps() {
    print_header "Installation Complete! 🎉"

    echo ""
    echo -e "${GREEN}Next Steps:${NC}"
    echo "  1. Restart your terminal (or run: exec zsh)"
    echo "  2. Review configs in: $DOTFILES_DIR"
    echo "  3. Customize the CONFIGS array in this script for your dotfiles"
    echo ""
    echo -e "${BLUE}Config Files:${NC}"

    for dest in ${(v)CONFIGS}; do
        echo "  $dest"
    done

    echo ""

    if command -v tmux &>/dev/null; then
        echo -e "${YELLOW}Tmux:${NC} Press 'prefix + I' to install plugins"
    fi

    echo ""
}

# -----------------------------------------------------------------------------
# Main Execution
# -----------------------------------------------------------------------------

main() {
    clear

    echo -e "${BLUE}╔════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  Simple Dotfiles Installer       ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════╝${NC}"

    detect_system
    create_directories
    install_packages
    install_neovim
    install_uv
    check_lazyvim_prereqs
    create_symlinks
    install_oh_my_zsh
    install_zsh_plugins
    setup_zsh
    setup_git
    install_docker
    install_nerd_fonts
    install_tmux_tpm
    show_next_steps
}

# Run the installer
main "$@"
