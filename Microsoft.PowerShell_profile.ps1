if ($Host.Name -eq 'ConsoleHost' -and [Environment]::UserInteractive) {
	oh-my-posh init pwsh --config 'catppuccin_macchiato' | Invoke-Expression

	Set-PSReadLineOption -PredictionSource History
	Set-PSReadLineOption -PredictionViewStyle ListView
	Set-PSReadLineOption -EditMode Emacs

	Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
	Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
	Set-PSReadLineKeyHandler -Key Tab       -Function MenuComplete

	Import-Module Terminal-Icons
	Import-Module z
}

Set-Alias c clear

Set-Alias ..  "cd.."
Set-Alias ~   "cd~"
Set-Alias l   "ls"
Set-Alias v   "nvim"

if (Test-Path "$HOME\.venv\Scripts\Activate.ps1") {
	& "$HOME\.venv\Scripts\Activate.ps1"
}
