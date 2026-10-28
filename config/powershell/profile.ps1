# PowerShell profile — symlinked to $PROFILE by install.ps1
# Equivalent of config/zsh/zshrc + aliases, for native Windows PowerShell.

# --- Prompt (oh-my-posh is the zsh-theme equivalent on Windows) ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh | Invoke-Expression
}

# --- zoxide (smart cd) ---
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init powershell --cmd z | Out-String) })
}

# --- fzf keybindings (via PSFzf module) ---
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- uv completions ---
if (Get-Command uv -ErrorAction SilentlyContinue) {
    (& uv generate-shell-completion powershell) | Out-String | Invoke-Expression
}
if (Get-Command uvx -ErrorAction SilentlyContinue) {
    (& uvx --generate-shell-completion powershell) | Out-String | Invoke-Expression
}

# --- Aliases (eza / bat replacements) ---
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function ls { eza --icons --group-directories-first @args }
    function ll { eza -l --icons --group-directories-first @args }
    function la { eza -la --icons --group-directories-first @args }
    function lt { eza --tree --level=2 --icons @args }
    function tree { eza --tree --icons @args }
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias cat bat
}

function nvim { uv run nvim @args }
Set-Alias vim nvim
Set-Alias v nvim

# --- Daily note (equivalent of the zsh `today` function) ---
function today {
    $vault = if ($env:OBSIDIAN_VAULT_PATH) { $env:OBSIDIAN_VAULT_PATH } else { "$HOME\my_brain" }
    $dir = Join-Path $vault "00_Inbox\Daily"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    $todayStr = Get-Date -Format "yyyy-MM-dd"
    $file = Join-Path $dir "$todayStr.md"

    if (-not (Test-Path $file)) {
        $last = Get-ChildItem -Path $dir -Filter "*.md" |
            Where-Object { $_.Name -ne "$todayStr.md" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 1

        $lines = @("# $todayStr", "", "## Today", "")

        if ($last) {
            $carried = Get-Content $last.FullName | Where-Object { $_ -match '^\- \[ \]' }
            $lines += $carried
        }

        $lines += @("- [ ] ", "", "## Notes", "")
        $lines | Out-File -FilePath $file -Encoding utf8
    }

    nvim $file
}
