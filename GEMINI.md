# 🚀 Gemini's Dotfiles Refactor

This `GEMINI.md` documents the refactoring process and the current state of your dotfiles, as guided by Gemini.

## ✨ Philosophy of this Refactor

The goal of this refactor was to create a clean, modern, and highly automated setup for your Linux development environment. Key principles included:

*   **Idempotency:** The `install.sh` script should be runnable multiple times without causing issues.
*   **Clarity & Readability:** The script uses colorful, informative, and slightly humorous logging to make the installation process engaging.
*   **Modularity:** Configuration files are organized into dedicated `config/` subdirectories.
*   **Latest Versions:** Where appropriate, tools are installed from their official sources to ensure the latest versions.

## 📦 Installation Scripts

The `install.sh` script is the heart of this setup. It's designed to be run on Debian-based Linux distributions (like Ubuntu) and handles the installation and configuration of all your essential tools.

### Key Features of `install.sh`:

*   **Informative Logging:** Uses custom `info`, `success`, `warn`, and `error` functions for clear feedback.
*   **`apt` Package Management:** Utilizes `sudo apt-get` for system-level package installations.
*   **Tool-Specific Installation:** Employs official installation methods for tools like `zoxide`, `starship`, and `neovim` to get the latest versions.
*   **Configuration Symlinking:** Creates symbolic links for `.zshrc`, `.tmux.conf`, and `starship.toml` to centralize configuration management within this repository.

### Tools Installed by `install.sh` (in order of execution):

1.  **`sudo apt-get update`**: Ensures package lists are up-to-date.
2.  **`zsh`**: The Z shell, configured with Oh My Zsh.
3.  **`create_zshrc_symlink`**: Links `~/.zshrc` to `config/zsh/.zshrc`.
4.  **`build-essential`**: Essential build tools (compilers, `make`).
5.  **`xclip` & `xsel`**: Clipboard utilities for `copyfile` plugin.
6.  **`zoxide`**: A smarter `cd` command.
7.  **`fzf`**: A command-line fuzzy finder.
8.  **`bat`**: A `cat` clone with syntax highlighting.
9.  **`ripgrep`**: A fast line-oriented search tool.
10. **`fd`**: A fast and user-friendly alternative to `find`.
11. **`starship`**: A minimal, blazing-fast, and customizable prompt.
12. **`create_starship_config_symlink`**: Links `~/.config/starship.toml` to `config/starship/starship.toml`.
13. **`neovim`**: Installed from official pre-built archives for the latest version.
14. **`JetBrainsMono Nerd Font`**: Installed for enhanced terminal glyphs and icons.
15. **`tree-sitter-cli`**: For enhanced syntax highlighting and parsing in Neovim.
16. **`LazyVim`**: A Neovim configuration framework.
17. **`tmux`**: A terminal multiplexer.
18. **`tpm`**: Tmux Plugin Manager.
19. **`create_tmux_symlink`**: Links `~/.tmux.conf` to `config/tmux/.tmux.conf`.
20. **`uv`**: A fast Python package installer and resolver.
21. **`docker`**: Docker Engine, CLI, and Containerd.

### `install_macos.sh`

This script is the macOS equivalent of `install.sh`. It uses Homebrew for package management and installs a similar set of tools, adapted for the macOS environment.

### Key Features of `install_macos.sh`:

*   **Homebrew Integration:** Installs and uses Homebrew to manage packages.
*   **macOS-Specific Tools:** Installs Xcode Command Line Tools and uses `brew` to install `neovim`, `tree-sitter`, and other command-line tools.
*   **Similar Toolset:** Aims to provide a consistent development environment across both Linux and macOS.

### Tools Installed by `install_macos.sh` (in order of execution):

1.  **`brew update`**: Ensures Homebrew formulae are up-to-date.
2.  **`zsh`**: The Z shell, configured with Oh My Zsh.
3.  **`create_zshrc_symlink`**: Links `~/.zshrc` to `config/zsh/.zshrc`.
4.  **`xcode-select --install`**: Installs the Xcode Command Line Tools.
5.  **`zoxide`**: A smarter `cd` command.
6.  **`fzf`**: A command-line fuzzy finder.
7.  **`bat`**: A `cat` clone with syntax highlighting.
8.  **`ripgrep`**: A fast line-oriented search tool.
9.  **`fd`**: A fast and user-friendly alternative to `find`.
10. **`starship`**: A minimal, blazing-fast, and customizable prompt.
11. **`create_starship_config_symlink`**: Links `~/.config/starship.toml` to `config/starship/starship.toml`.
12. **`neovim`**: Installed via Homebrew.
13. **`tree-sitter`**: For enhanced syntax highlighting and parsing in Neovim.
14. **`LazyVim`**: A Neovim configuration framework.
15. **`tmux`**: A terminal multiplexer.
16. **`tpm`**: Tmux Plugin Manager.
17. **`create_tmux_symlink`**: Links `~/.tmux.conf` to `config/tmux/.tmux.conf`.
18. **`uv`**: A fast Python package installer and resolver.

## ⚙️ Configuration Files

Your configuration files are now organized within the `config/` directory:

*   **`config/zsh/.zshrc`**: Your main Zsh configuration, including Oh My Zsh setup, plugins, aliases, `fzf` integration, `zoxide` initialization, and `starship` initialization.
*   **`config/tmux/.tmux.conf`**: Your Tmux configuration, currently set up to initialize `tpm`.
*   **`config/starship/starship.toml`**: Your Starship prompt configuration (currently empty, ready for your customization).

## 🚀 Getting Started

To set up a new machine with these dotfiles:

1.  **Clone this repository:**
    ```bash
    git clone <your-repo-url> ~/.dotfiles
    ```
2.  **Navigate into the directory:**
    ```bash
    cd ~/.dotfiles
    ```
3.  **Run the appropriate installation script for your OS:**

    *   **For Linux (Debian/Ubuntu):**
        ```bash
        ./install.sh
        ```
    *   **For macOS:**
        ```bash
        ./install_macos.sh
        ```

4.  **Log out and log back in (or restart your terminal):** This ensures all changes, especially user group additions (like `docker` on Linux) and shell configurations, take effect.

## 📝 Customization

Feel free to customize the configuration files located in the `config/` directory. Any changes you make there will be version-controlled and applied to your system via the symlinks.

Enjoy your streamlined and powerful development environment! ✨
