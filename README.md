# 🚀 My Personal Dotfiles

This repository contains my personal dotfiles, meticulously crafted to set up a consistent, productive, and aesthetically pleasing development environment across macOS and Linux systems. The goal is to automate the setup of my shell, tools, and configurations with a single, idempotent command.

## ✨ Features & Philosophy

This setup is built around a modern Zsh shell experience, enhanced by a curated set of command-line tools and a focus on efficient workflows.

*   **Modern Shell:** Zsh powered by Oh My Zsh with the robbyrussell theme, enhanced with custom plugins (fzf-tab, you-should-use, fast-syntax-highlighting)
*   **Optimized Workflow:** Integrates tools for fuzzy finding (`fzf`), smart directory navigation (`zoxide`), enhanced ls (`eza`, `bat`), and powerful searching (`ripgrep`, `fd`)
*   **Enhanced Editing:** Neovim configured with LazyVim, providing a feature-rich and highly customizable editing experience
*   **Terminal Powerhouse:** Tmux with TPM (Tmux Plugin Manager) for robust terminal multiplexing and session management
*   **Terminal Emulator:** WezTerm configuration included (manual setup required)
*   **Git Tools:** LazyGit for an intuitive TUI git interface
*   **Containerization Ready:** Docker for seamless application containerization
*   **Python Development:** `uv` for extremely fast Python package and environment management
*   **Organized Configuration:** All configurations are neatly organized within a `config/` directory and symlinked to their respective locations

## 📦 Installation

The setup process is automated by `install.sh` (macOS, Linux — Debian/Ubuntu,
Arch, and Raspberry Pi OS) or `install.ps1` (native Windows PowerShell).

### Prerequisites

*   `git` and `curl` must be installed on your system
*   On macOS: Homebrew will be checked (install from https://brew.sh if missing)
*   On Linux: `apt` (Debian/Ubuntu/Raspberry Pi OS) or `pacman` (Arch) package manager
*   On Windows: `winget` (ships with Windows 11 / recent Windows 10 via "App
    Installer" from the Microsoft Store), PowerShell 5.1+

### Windows Installation

```powershell
git clone https://github.com/imtorrr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.ps1
```

Symlinking configs (PowerShell profile, Neovim config, WezTerm config) needs
either an **elevated (Administrator) PowerShell**, or **Developer Mode**
enabled (Settings → Privacy & Security → For developers). Without one of
those, Windows blocks symlink creation and that step will fail with a clear
message telling you which to use.

The Windows side uses a different ecosystem than zsh (no Oh My Zsh equivalent
natively) — `oh-my-posh` replaces the Oh My Zsh theme, and `PSFzf` replaces
the shell-native fzf keybindings. Everything else (Neovim/LazyVim, WezTerm,
the daily-note `today` function) is functionally equivalent across all
platforms.

### Installation Steps

1.  **Clone the repository:**

    ```sh
    git clone https://github.com/imtorrr/dotfiles.git ~/.dotfiles
    ```

2.  **Run the installation script:**

    ```sh
    cd ~/.dotfiles
    ./install.sh
    ```

    Or for non-interactive mode (auto-accept all prompts):

    ```sh
    ./install.sh -y
    ```

### What the Script Does

The installer will:

*   **Detect your system:** Identifies macOS, Debian/Ubuntu, or Arch Linux
*   **Install packages:** Core tools including git, neovim (latest version), tmux, zsh, fzf, ripgrep, bat, eza, fd, zoxide, uv, lazygit, and python
*   **Set up Zsh:** Installs Oh My Zsh and custom plugins (fzf-tab, you-should-use, fast-syntax-highlighting)
*   **Configure Neovim:** Downloads and installs the latest Neovim version with LazyVim
*   **Install Docker:** Sets up Docker Engine (Linux) or Docker Desktop (macOS)
*   **Install fonts:** JetBrainsMono Nerd Font for proper icon display
*   **Set up Tmux:** Installs TPM (Tmux Plugin Manager)
*   **Create symlinks:** Links all configuration files to their proper locations
    *   `~/.zshrc` → `config/zsh/zshrc`
    *   `~/.config/zsh/.aliases` → `config/zsh/aliases`
    *   `~/.config/nvim` → `config/nvim`
    *   `~/.tmux.conf` → `config/tmux/tmux.conf`

## Post-Installation

After the script finishes:

1.  **Change your default shell to Zsh** (if it isn't already):
    ```sh
    chsh -s $(which zsh)
    ```
2.  **Log out and log back in (or restart your terminal):** This is crucial for all changes, especially user group additions (like `docker`) and shell configurations, to take full effect.
3.  **Open Neovim:** The first launch of Neovim with LazyVim will trigger plugin installations.

Enjoy your new, streamlined, and powerful development environment! ✨