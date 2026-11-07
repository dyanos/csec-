<#
.SYNOPSIS
  Builds tessera-lsp and the OpenIDEA plugin, and packs tessera-lang.tessera-<version>.oiplugin.

.PARAMETER Install
  Also `cargo install` tessera-lsp into ~/.cargo/bin (the IDE starts it by name from PATH).

.PARAMETER Test
  Run the unit tests and the end-to-end LSP smoke test first.

.EXAMPLE
  powershell -File editors/openidea-tessera/scripts/build.ps1 -Test -Install
#>
param([switch]$Install, [switch]$Test)
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $PSScriptRoot          # editors/openidea-tessera
$repo = Split-Path -Parent (Split-Path -Parent $here)
$cargoBin = Join-Path $env:USERPROFILE '.cargo\bin'
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) { $env:PATH = "$cargoBin;$env:PATH" }

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
function Run([string]$exe, [string[]]$argv, [string]$cwd) {
    Push-Location $cwd
    try {
        & $exe @argv
        if ($LASTEXITCODE -ne 0) { throw "$exe $($argv -join ' ') failed ($LASTEXITCODE)" }
    } finally { Pop-Location }
}

if ($Test) {
    Step 'tests: tessera-syntax, tessera-lsp'
    Run cargo @('test', '--quiet') $here
    Step 'tests: plugin'
    Run cargo @('test', '--quiet') (Join-Path $here 'plugin')
}

Step 'build tessera-lsp (release)'
Run cargo @('build', '--release', '-p', 'tessera-lsp') $here
$lsp = Join-Path $here 'target\release\tessera-lsp.exe'

if ($Test) {
    Step 'smoke test tessera-lsp'
    Run python @('-I', (Join-Path $here 'scripts\smoke_lsp.py'), $lsp, $repo) $here
}

Step 'build plugin component (wasm32-wasip2)'
Run rustup @('target', 'add', 'wasm32-wasip2') $here
$plugin = Join-Path $here 'plugin'
Run cargo @('build', '--release', '--target', 'wasm32-wasip2') $plugin
New-Item -ItemType Directory -Force (Join-Path $plugin 'dist') | Out-Null
Copy-Item (Join-Path $plugin 'target\wasm32-wasip2\release\openidea_plugin_tessera.wasm') (Join-Path $plugin 'dist\plugin.wasm') -Force

$version = (Select-String -Path (Join-Path $plugin 'plugin.toml') -Pattern '^version\s*=\s*"([^"]+)"').Matches[0].Groups[1].Value
$package = Join-Path $here "tessera-lang.tessera-$version.oiplugin"
$tool = Get-Command openidea-plugin -ErrorAction SilentlyContinue
if (-not $tool) { $tool = Get-Command (Join-Path $env:USERPROFILE '.openidea-plugin-tool\bin\openidea-plugin.exe') -ErrorAction SilentlyContinue }

if ($tool) {
    Step 'openidea-plugin check'
    Run $tool.Source @('check', $plugin) $here
}

Step "pack $([IO.Path]::GetFileName($package))"
$stage = Join-Path ([IO.Path]::GetTempPath()) "tessera-oiplugin-$PID"
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory $stage | Out-Null
foreach ($item in 'plugin.toml', 'README.md', 'languages', 'icons', 'templates', 'dist') {
    $src = Join-Path $plugin $item
    if (Test-Path $src) { Copy-Item $src (Join-Path $stage $item) -Recurse }
}
Copy-Item (Join-Path $here 'LICENSE') (Join-Path $stage 'LICENSE') -ErrorAction SilentlyContinue
Remove-Item $package -ErrorAction SilentlyContinue
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($stage, $package)
Remove-Item $stage -Recurse -Force
if ($tool) { Run $tool.Source @('check', $package) $here }

if ($Install) {
    Step 'install tessera-lsp into ~/.cargo/bin'
    Run cargo @('install', '--path', 'crates/tessera-lsp', '--locked', '--force') $here
    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User') -split ';'
    if (-not ($userPath | Where-Object { $_.TrimEnd('\') -ieq $cargoBin })) {
        Write-Warning "$cargoBin is not on your user PATH, so OpenIDEA can't start tessera-lsp by name. Add it with:`n  [Environment]::SetEnvironmentVariable('PATH', [Environment]::GetEnvironmentVariable('PATH','User') + ';$cargoBin', 'User')`nthen restart OpenIDEA."
    }
}

Write-Host ''
Write-Host "Language server : $lsp"
Write-Host "Plugin package  : $package"
Write-Host 'Install it in OpenIDEA: Settings > Plugins > gear > Install Plugin from Package File...'
