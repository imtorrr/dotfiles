#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles installer for native Windows PowerShell.
.DESCRIPTION
    Windows counterpart to install.sh (zsh/macOS/Linux). Uses winget for
    packages and symlinks config/powershell/profile.ps1 to $PROFILE.
.PARAMETER Yes
    Auto-accept all prompts (non-interactive mode).
#>

param(
    [switch]$Yes
)

$ErrorActionPreference = "Stop"
$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Header($msg) { Write-Host ""; Write-Host "==> $msg" -ForegroundColor Blue }
function Write-Success($msg) { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Err($msg) { Write-Host "[X] $msg" -ForegroundColor Red }
function Write-Warn($msg) { Write-Host "[!] $msg" -ForegroundColor Yellow }

function Confirm-Action($prompt) {
    if ($Yes) {
        Write-Host "? $prompt (y/n): y (auto-accepted)" -ForegroundColor Yellow
        return $true
    }
    $response = Read-Host "? $prompt (y/n)"
    return $response -match '^[Yy]'
}

# -----------------------------------------------------------------------------
# Admin / symlink capability check
# -----------------------------------------------------------------------------
# Creating symlinks on Windows needs either an elevated (Administrator) shell,
# OR Developer Mode enabled (Settings > Privacy & Security > For developers).
function Test-CanSymlink {
    $principal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) { return $true }

    try {
        $devMode = Get-ItemPropertyValue -Path `
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" `
            -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction Stop
        return $devMode -eq 1
    } catch {
        return $false
    }
}

# -----------------------------------------------------------------------------
# Packages (winget)
# -----------------------------------------------------------------------------
$WingetPackages = @(
    "Git.Git",
    "Neovim.Neovim",
    "junegunn.fzf",
    "BurntSushi.ripgrep.MSVC",
    "sharkdp.bat",
    "eza-community.eza",
    "ajeetdsouza.zoxide",
    "astral-sh.uv",
    "JesseDuffield.lazygit",
    "Python.Python.3.12",
    "Docker.DockerDesktop",
    "ObsidianMD.Obsidian",
    "Starship.Starship",
    "ellie.atuin",
    "direnv.direnv"
)

function Install-Packages {
    Write-Header "Package Installation"

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Err "winget not found. Install 'App Installer' from the Microsoft Store first."
        return
    }

    if (-not (Confirm-Action "Install development packages via winget?")) {
        Write-Warn "Skipping package installation"
        return
    }

    foreach ($pkg in $WingetPackages) {
        $installed = winget list --id $pkg --exact 2>$null | Select-String $pkg
        if ($installed) {
            Write-Success "$pkg (already installed)"
        } else {
            Write-Host "Installing $pkg..."
            winget install --id $pkg --exact --silent --accept-package-agreements --accept-source-agreements
            Write-Success "$pkg installed"
        }
    }

    Write-Success "Package installation complete! (restart shell for PATH updates)"
}

function Install-PSFzf {
    Write-Header "PSFzf Module"

    if (Get-Module -ListAvailable -Name PSFzf) {
        Write-Success "PSFzf already installed"
        return
    }

    if (-not (Confirm-Action "Install PSFzf module (fzf keybindings for PowerShell)?")) {
        Write-Warn "Skipping PSFzf"
        return
    }

    Install-Module -Name PSFzf -Scope CurrentUser -Force
    Write-Success "PSFzf installed"
}

function Install-NerdFont {
    Write-Header "Nerd Font"

    $fontName = "JetBrainsMono"
    $fontsFolder = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"

    if (Get-ChildItem -Path $fontsFolder -Filter "*$fontName*NerdFont*" -ErrorAction SilentlyContinue) {
        Write-Success "$fontName Nerd Font already installed"
        return
    }

    if (-not (Confirm-Action "Install $fontName Nerd Font?")) {
        Write-Warn "Skipping Nerd Font"
        return
    }

    $tempZip = "$env:TEMP\$fontName.zip"
    $tempDir = "$env:TEMP\nerd-fonts-$fontName"
    $url = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$fontName.zip"

    Write-Host "Downloading $fontName Nerd Font..."
    Invoke-WebRequest -Uri $url -OutFile $tempZip
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    New-Item -ItemType Directory -Force -Path $fontsFolder | Out-Null
    Get-ChildItem -Path $tempDir -Filter "*.ttf" | ForEach-Object {
        Copy-Item $_.FullName -Destination $fontsFolder -Force
    }

    Remove-Item $tempZip, $tempDir -Recurse -Force
    Write-Success "$fontName Nerd Font installed (restart terminal to see it in the font list)"
}

# -----------------------------------------------------------------------------
# Config symlinks
# -----------------------------------------------------------------------------
function New-ConfigSymlink($source, $dest) {
    $src = Join-Path $DotfilesDir $source
    if (-not (Test-Path $src)) {
        Write-Warn "Source not found: $source (skipping)"
        return
    }

    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.LinkType) {
            Remove-Item $dest -Force
        } else {
            $backup = "$dest.backup.$(Get-Date -Format yyyyMMdd_HHmmss)"
            Move-Item $dest $backup
            Write-Warn "Backed up: $(Split-Path -Leaf $dest) -> $(Split-Path -Leaf $backup)"
        }
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    New-Item -ItemType SymbolicLink -Path $dest -Target $src | Out-Null
    Write-Success "Linked: $source -> $dest"
}

function Install-ConfigSymlinks {
    Write-Header "Creating symlinks"

    if (-not (Test-CanSymlink)) {
        Write-Err "Cannot create symlinks: run as Administrator, or enable Developer Mode"
        Write-Err "(Settings > Privacy & Security > For developers > Developer Mode)"
        return
    }

    if (-not (Confirm-Action "Create symlinks for config files?")) {
        Write-Warn "Skipping symlink creation"
        return
    }

    New-ConfigSymlink "config\powershell\profile.ps1" $PROFILE
    New-ConfigSymlink "config\nvim" "$env:LOCALAPPDATA\nvim"
    New-ConfigSymlink "config\wezterm\wezterm.lua" "$env:USERPROFILE\.wezterm.lua"
    New-ConfigSymlink "config\starship.toml" "$env:USERPROFILE\.config\starship.toml"

    Write-Success "Symlinks created successfully!"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
function Main {
    Write-Host "==================================" -ForegroundColor Blue
    Write-Host "  Dotfiles Installer (Windows)" -ForegroundColor Blue
    Write-Host "==================================" -ForegroundColor Blue

    Write-Header "Detecting system"
    Write-Host "OS: Windows $([System.Environment]::OSVersion.Version)"
    Write-Success "System detected"

    Install-Packages
    Install-PSFzf
    Install-NerdFont
    Install-ConfigSymlinks

    Write-Header "Installation Complete!"
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  1. Restart PowerShell (or run: . `$PROFILE)"
    Write-Host "  2. If symlinks failed, re-run as Administrator or enable Developer Mode"
    Write-Host "  3. Set `$env:OBSIDIAN_VAULT_PATH to your vault path (for the 'today' function)"
    Write-Host ""
}

Main
