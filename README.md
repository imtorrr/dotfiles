# 🚀 My Personal Dotfiles

This repository contains my personal dotfiles for setting up a consistent and productive development environment across macOS and Ubuntu. The goal is to automate the setup of my shell, tools, and configurations on any new machine with a single command.

## ✨ Features

This setup is built around Zsh and a curated set of tools to enhance productivity and developer experience.

- **Shell**: Zsh configured with [Oh My Zsh](https://ohmyzsh.com/) for powerful plugin management and theming.
- **Prompt**: The clean and informative `bira` theme.
- **Cross-Platform**: An idempotent installation script that works on both **macOS** (with Homebrew) and **Ubuntu/Debian** (with APT).
- **Key Tools Installed**:
  - `neovim`: My preferred terminal-based text editor.
  - `zoxide`: A smarter `cd` command that learns your habits.
  - `fzf`: A command-line fuzzy finder for blazing fast search.
  - `bat`: A `cat` clone with syntax highlighting and Git integration.
  - `uv`: An extremely fast Python package installer and resolver.
  - `tmux`: A terminal multiplexer to manage multiple sessions.
  - `gcloud`: The Google Cloud CLI.
- **Key Zsh Plugins**:
  - `zsh-autosuggestions`: Fish-like autosuggestions for commands.
  - `zsh-syntax-highlighting`: Provides syntax highlighting for the shell.
  - `you-should-use`: Reminds you to use existing aliases for commands you just typed.
  - And many more for `git`, `docker`, `history`, etc.

---

## 📦 Installation

The setup process is automated by the `install.sh` script.

### Prerequisites

You need `git` and `curl` to be installed on your system before you begin.

### Steps

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

- Detect your OS (macOS or Ubuntu).
- Install the necessary dependencies using the native package manager.
- Install Oh My Zsh and the required custom plugins.
- Create a backup of your existing `.zshrc` (if any) to `.zshrc.bak`.
- Create a symbolic link from `~/.zshrc` to the file in this repository.

---

## Post-Installation

After the script finishes, you may need to perform these two final steps:

1.  **Change your default shell to Zsh** (if it isn't already):
    ```sh
    chsh -s $(which zsh)
    ```
2.  **Restart your terminal** for all changes to take effect.

Enjoy your new, streamlined development environment!
