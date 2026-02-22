# AGENTS.md - Development Guidelines for Agentic Coding

This document provides guidelines for agentic coding agents operating in this dotfiles repository.

## Repository Overview

This is a personal dotfiles repository containing:
- **Zsh shell** configuration with Oh My Zsh
- **Neovim** configuration (LazyVim-based)
- **Tmux** terminal multiplexer config
- **Installation scripts** for Linux and macOS
- **Development tool configs** (Docker, Python, etc.)

## Build/Test/Lint Commands

### Installation
```bash
./install.sh                    # Linux/macOS installer (interactive)
./install.sh -y                 # Auto-accept all prompts (non-interactive)
./install.sh --help             # Show help
```

### Validation
```bash
# Lint shell scripts (requires shellcheck)
shellcheck install.sh

# Check Lua syntax (requires luac)
luac -p config/nvim/lua/**/*.lua

# Validate Zsh syntax
zsh -n config/zsh/zshrc
```

### Single File Testing
```bash
# Test shell script functions (run install.sh with -y flag)
./install.sh -y

# Validate specific config file
zsh -n config/zsh/aliases
```

## Code Style Guidelines

### Shell Scripts (.sh)
- **Language**: Zsh (not bash) for associative array support
- **Shebang**: Use `#!/usr/bin/env zsh`
- **Set options**: Use `set -e` for error handling
- **Indentation**: 4 spaces
- **Quotes**: Always quote variables: `"$VAR"`
- **Functions**: Use `function_name() { }` syntax
- **Error messages**: Use stderr redirection `>&2`
- **Variable naming**: UPPERCASE for global constants, lowercase for locals
- **Comments**: Use `#` with space: `# comment`

### Lua Scripts (Neovim config)
- **Indentation**: 2 spaces (per LazyVim convention)
- **Formatter**: Use stylua (config: config/nvim/stylua.toml)
- **Imports**: Organize by: standard library, third-party, local modules
- **Naming**: snake_case for functions/variables, UPPERCASE for constants
- **Comments**: Use `--` with space: `-- comment`
- **Functions**: Prefer local scope: `local function name() end`
- **Error handling**: Use vim.notify() for user messages

### Zsh Configuration
- **Indentation**: 4 spaces
- **Variable naming**: UPPERCASE for environment variables, lowercase for internal
- **Array syntax**: Use `(element1 element2)` for simpler syntax
- **Path expansion**: Quote variables to prevent globbing: `"$PATH"`
- **Plugins**: Load via oh-my-zsh plugins array in zshrc

### JSON/YAML Configuration
- **Indentation**: 2 spaces
- **Keys**: Use camelCase for JSON, lowercase-with-hyphens for YAML
- **Trailing commas**: No trailing commas in JSON
- **Comments**: YAML uses `#`, JSON doesn't support comments

## Naming Conventions

### Functions
- **Bash/Zsh**: `snake_case` with descriptive names
  - `install_neovim()`, `check_lazyvim_prereqs()`, `print_success()`
- **Lua**: `snake_case`
  - `setup_keymaps()`, `configure_lsp()`

### Variables
- **Constants**: `UPPERCASE_WITH_UNDERSCORES`
  - `DOTFILES_DIR`, `BREW_PACKAGES`, `nvim_version`
- **Locals**: `lowercase_with_underscores`
  - `pkg_manager`, `is_wsl`, `temp_dir`

### Files/Directories
- **Config files**: lowercase with dots (e.g., `zshrc`, `stylua.toml`)
- **Directories**: lowercase (e.g., `config/nvim/lua/plugins`)
- **Shell scripts**: `.sh` extension

## Imports & Dependencies

### Zsh
- Use Oh My Zsh for plugin management (config/zsh/zshrc)
- Plugin order matters: fast-syntax-highlighting must be last
- Source external configs conditionally: `[ -f "$FILE" ] && source "$FILE"`

### Lua (Neovim)
- Use LazyVim plugin manager (config/nvim/lazy-lock.json)
- Organize into logical plugin specs in config/nvim/lua/plugins/
- Core config in config/nvim/lua/config/

### Shell Script Dependencies
- Check for command availability: `if command -v cmd &>/dev/null; then`
- Detect OS: Use `uname -s | tr '[:upper:]' '[:lower:]'`
- Support macOS (darwin), Linux (apt/pacman), and WSL

## Error Handling

### Shell Scripts
```bash
# Use set -e for early exit on error
set -e

# Use || true for optional commands
command_that_might_fail || true

# Check command existence
if ! command -v nvim &>/dev/null; then
    print_error "nvim not found"
    exit 1
fi

# Provide clear error messages
print_error "Installation failed"
```

### Lua
```lua
-- Use pcall for error handling
local ok, result = pcall(function_call)
if not ok then
  vim.notify("Error: " .. result, vim.log.levels.ERROR)
end

-- Use vim.notify for user messages
vim.notify("Setup complete", vim.log.levels.INFO)
```

## Key Directories

```
/Users/imtorrr/dotfiles/
├── install.sh              # Main installer (Zsh)
├── config/
│   ├── zsh/
│   │   ├── zshrc          # Main zsh config
│   │   └── aliases        # Shell aliases
│   ├── nvim/
│   │   ├── init.lua       # Neovim entry point
│   │   ├── lua/
│   │   │   ├── config/    # Core config (keymaps, options, etc.)
│   │   │   └── plugins/   # Plugin specs
│   │   └── stylua.toml    # Lua formatter config
│   ├── tmux/
│   │   └── tmux.conf      # Tmux configuration
│   └── wezterm/           # Terminal emulator config
├── README.md              # Installation guide
└── AGENTS.md              # This file
```

## Important Implementation Details

### OS Detection & Package Managers
- macOS uses Homebrew (`brew`)
- Linux: Debian/Ubuntu uses `apt`, Arch uses `pacman`
- WSL detection: Check `/proc/version` for "microsoft"
- Always check if pkg manager is installed before use

### Symlink Creation
- Backup existing files: `filename.backup.$(date +%Y%m%d_%H%M%S)`
- Remove old symlinks/files before creating new ones
- Create parent directories: `mkdir -p "$(dirname "$dest")"`

### File Paths
- Use `$HOME` not `~` in scripts
- Quote all path variables: `"$PATH"` not $PATH
- Use absolute paths in symlinks

## LazyVim Configuration

The Neovim config uses LazyVim with extras for:
- Language support: Python, TypeScript, JSON, YAML, Markdown, Docker, TOML
- Tools: ESLint, Biome, Git
- Plugins: Telescope, Mini-files, Snacks picker, Claude Code

See `config/nvim/lazyvim.json` for enabled extras.

## Best Practices for Agents

1. **Test before committing**: Run installation script in dry-run mode
2. **Preserve existing configs**: Always backup before modifying
3. **Check compatibility**: Verify OS/package manager before install commands
4. **Quote variables**: Prevent unexpected globbing and word splitting
5. **Use meaningful variable names**: Clarity over brevity
6. **Add comments for complex logic**: Especially in install.sh
7. **Handle missing dependencies gracefully**: Inform user, don't fail silently
8. **Validate syntax**: Use `shellcheck`, `luac`, `stylua` before commit
