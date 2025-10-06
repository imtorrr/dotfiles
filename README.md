# 🚀 My Personal Dotfiles

This repository contains my personal dotfiles, meticulously crafted to set up a consistent, productive, and aesthetically pleasing development environment across Linux systems. The goal is to automate the setup of my shell, tools, and configurations with a single, idempotent command.

## ✨ Features & Philosophy

This setup is built around a modern Zsh shell experience, enhanced by a curated set of command-line tools and a focus on efficient workflows.

*   **Modern Shell:** Zsh, powered by Oh My Zsh, with a blazing-fast Starship prompt.
*   **Optimized Workflow:** Integrates tools for fuzzy finding (`fzf`), smart directory navigation (`zoxide`), and powerful text searching (`ripgrep`, `fd`).
*   **Enhanced Editing:** Neovim, configured with LazyVim, providing a feature-rich and highly customizable editing experience.
*   **Terminal Powerhouse:** Tmux for robust terminal multiplexing and session management.
*   **Containerization Ready:** Docker for seamless application containerization.
*   **Python Development:** `uv` for extremely fast Python package management.
*   **Organized Configuration:** All configurations are neatly organized within a `config/` directory and symlinked to their respective locations.

For a detailed log of the refactoring process and the current state of the dotfiles, please refer to [GEMINI.md](GEMINI.md).

## 📦 Installation

The setup process is fully automated by the `install.sh` script for Linux and `install_macos.sh` for macOS.

### Prerequisites

You need `git` and `curl` to be installed on your system before you begin.

### Linux Steps

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/imtorrr/dotfiles.git ~/.dotfiles
    ```

2.  **Run the installation script:**

    ```sh
    cd ~/.dotfiles
    ./install.sh
    ```

    The script will:
    *   Detect your Linux distribution (Debian-based systems like Ubuntu are supported).
    *   Install all necessary system dependencies and tools.
    *   Set up Oh My Zsh and its plugins.
    *   Install and configure Neovim, Starship, Tmux, Docker, and other utilities.
    *   Create symbolic links for all configuration files.

### macOS Steps

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/imtorrr/dotfiles.git ~/.dotfiles
    ```

2.  **Run the installation script:**

    ```sh
    cd ~/.dotfiles
    ./install_macos.sh
    ```

    The script will:
    *   Install Homebrew (if not already installed).
    *   Install all necessary system dependencies and tools via Homebrew.
    *   Set up Oh My Zsh and its plugins.
    *   Install and configure Neovim, Starship, Tmux, and other utilities.
    *   Create symbolic links for all configuration files.

## Post-Installation

After the script finishes:

1.  **Change your default shell to Zsh** (if it isn't already):
    ```sh
    chsh -s $(which zsh)
    ```
2.  **Log out and log back in (or restart your terminal):** This is crucial for all changes, especially user group additions (like `docker`) and shell configurations, to take full effect.
3.  **Open Neovim:** The first launch of Neovim with LazyVim will trigger plugin installations.

Enjoy your new, streamlined, and powerful development environment! ✨