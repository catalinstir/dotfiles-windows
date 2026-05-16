echo "Hello from $PROFILE"
# Theme
oh-my-posh init pwsh --config 'catppuccin_macchiato' | Invoke-Expression

Set-Alias c clear

Set-Alias ..  "cd.."
Set-Alias ~   "cd~"

# Py env
& "$HOME\.venv\Scripts\Activate.ps1"
# Autosuggestion & Syntax
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Modules
Import-Module Terminal-Icons
Import-Module z
# Import-Module PSFzf
# Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+f' -PSReadlineChordReverseHistory 'Ctrl+r'


