# setup-nvim.ps1
#
# Installs everything the nvim config needs, then links %LOCALAPPDATA%\nvim
# to the nvim/ dir in this repo. Safe to re-run.
#
# Assumes this script sits at the repo root, with the nvim config at ./nvim/.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Scoop ------------------------------------------------------------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "[+] Installing scoop..." -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri 'https://get.scoop.sh' | Invoke-Expression
}

scoop update
scoop install git   # needed for `scoop bucket add`

if (-not (scoop bucket list | Where-Object Name -eq 'extras')) {
    scoop bucket add extras
}

# --- Packages (scoop) -------------------------------------------------------
# ripgrep + fd     -> telescope live_grep / find_files
# tree-sitter      -> nvim-treesitter parser builds
# nodejs-lts       -> LSPs installed by Mason (tsserver, pyright, ...)
# python           -> pynvim + several LSPs
# llvm             -> clang (nice to have; MSVC still needed for TS linker)
$packages = @(
    'neovim',
    'ripgrep',
    'fd',
    'tree-sitter',
    'nodejs-lts',
    'python',
    'llvm'
)
foreach ($p in $packages) {
    scoop install $p
}

# --- MSVC Build Tools (winget - not on scoop) -------------------------------
# nvim-treesitter's Rust CLI hardcodes --target=x86_64-pc-windows-msvc,
# so cl.exe + link.exe from MSVC are required no matter which C compiler
# you use as CC. ~3 GB, one-time.
$hasMsvc = Get-ChildItem "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -ErrorAction SilentlyContinue
if (-not $hasMsvc) {
    Write-Host "[+] Installing Visual Studio Build Tools (large)..." -ForegroundColor Cyan
    winget install --id Microsoft.VisualStudio.2022.BuildTools --exact --silent `
        --override "--wait --passive --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
} else {
    Write-Host "[=] MSVC Build Tools already present."
}

# --- Junction %LOCALAPPDATA%\nvim -> repo config ----------------------------
$repoNvim = Join-Path $PSScriptRoot 'nvim'
if (-not (Test-Path (Join-Path $repoNvim 'init.lua'))) {
    throw "No init.lua under $repoNvim"
}

$link = Join-Path $env:LOCALAPPDATA 'nvim'
if (Test-Path $link) {
    $item = Get-Item $link -Force
    $already = ($item.LinkType -eq 'Junction' -and $item.Target -contains $repoNvim)
    if ($already) {
        Write-Host "[=] nvim config already linked."
    } else {
        $bak = "$link.bak.$(Get-Date -Format yyyyMMddHHmmss)"
        Move-Item $link $bak
        Write-Host "[!] Existing nvim config backed up to $bak"
        New-Item -ItemType Junction -Path $link -Target $repoNvim | Out-Null
        Write-Host "[+] Linked $link -> $repoNvim"
    }
} else {
    New-Item -ItemType Junction -Path $link -Target $repoNvim | Out-Null
    Write-Host "[+] Linked $link -> $repoNvim"
}

Write-Host ""
Write-Host "Done." -ForegroundColor Green
Write-Host "Launch nvim from a shell with MSVC on PATH (or add Enter-VsDevShell to your pwsh profile)." -ForegroundColor Yellow
