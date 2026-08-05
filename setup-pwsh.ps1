# setup-pwsh.ps1
#
# Bootstraps everything needed for the pwsh profile in this repo, then links
# $PROFILE -> Microsoft.PowerShell_profile.ps1. Safe to re-run.
#
# Assumes this script and Microsoft.PowerShell_profile.ps1 live in the same dir.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Scoop ------------------------------------------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing scoop..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}

scoop update

# Buckets need git; install it first so `scoop bucket add` works.
scoop install git

foreach ($b in @('extras', 'nerd-fonts')) {
    if (-not (scoop bucket list | Where-Object Name -eq $b)) {
        scoop bucket add $b
    }
}

# --- Packages (scoop) -------------------------------------------------------
$packages = @(
    'pwsh',         # PowerShell 7
    'oh-my-posh',   # prompt engine
    'Meslo-NF'      # Nerd Font for the catppuccin_macchiato theme glyphs
)
foreach ($p in $packages) {
    scoop install $p    # scoop skips already-installed apps
}

# --- PowerShell modules (PSGallery, not on scoop) ---------------------------
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

foreach ($m in @('Terminal-Icons', 'z', 'PSReadLine')) {
    if (-not (Get-Module -ListAvailable -Name $m)) {
        Install-Module $m -Scope CurrentUser -Force -SkipPublisherCheck
    }
}

# --- Link $PROFILE -> repo profile ------------------------------------------
$repoProfile = Join-Path $PSScriptRoot 'Microsoft.PowerShell_profile.ps1'
if (-not (Test-Path $repoProfile)) {
    throw "Profile not found: $repoProfile"
}

# Ask pwsh 7 where its profile lives (not the 5.1 one).
$profilePath = & pwsh -NoProfile -Command '$PROFILE'
New-Item -ItemType Directory -Force -Path (Split-Path $profilePath) | Out-Null

if (Test-Path $profilePath) {
    $existing = Get-Item $profilePath -Force
    $already  = ($existing.LinkType -and $existing.Target -contains $repoProfile)
    if ($already) {
        Write-Host "[=] Profile already linked."
    } else {
        $bak = "$profilePath.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Move-Item $profilePath $bak
        Write-Host "[!] Existing profile backed up to $bak"
        # HardLink works without admin/dev-mode; edits visible from both paths.
        New-Item -ItemType HardLink -Path $profilePath -Target $repoProfile | Out-Null
        Write-Host "[+] Linked $profilePath -> $repoProfile"
    }
} else {
    New-Item -ItemType HardLink -Path $profilePath -Target $repoProfile | Out-Null
    Write-Host "[+] Linked $profilePath -> $repoProfile"
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Next: open a new pwsh window and set 'MesloLGM Nerd Font' in Windows Terminal." -ForegroundColor Yellow
