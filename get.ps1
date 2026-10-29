# Codex x NotebookLM MCP - one-line launcher for Windows PowerShell
#
#   irm https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/get.ps1 | iex
#
# This file is ASCII-only on purpose, so it works with "irm | iex" in Windows PowerShell 5.1.
# It downloads the whole project to a temp folder, then runs install.ps1 (Chinese messages).
#
# To pass options:
#   & ([scriptblock]::Create((irm https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/get.ps1))) -DryRun
[CmdletBinding()]
param(
  [string]$Name = 'notebooklm',
  [switch]$SkipInstall,
  [switch]$SkipAuth,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

$archive = if ($env:CODEX_NLM_ARCHIVE_URL) { $env:CODEX_NLM_ARCHIVE_URL } else { 'https://github.com/jyuli780-rgb/notebk-cx-mcp/archive/refs/heads/main.zip' }
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ('codex-nlm-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tmp | Out-Null
$zip = Join-Path $tmp 'repo.zip'

Write-Host 'Downloading installer ...'
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing -Uri $archive -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $tmp -Force
} catch {
  Write-Host '[X] Download failed. Check your network, or use git clone and run install.cmd.' -ForegroundColor Red
  return
}

$sub = Get-ChildItem -Path $tmp -Directory | Select-Object -First 1
$installer = Join-Path $sub.FullName 'install.ps1'
if (-not (Test-Path $installer)) {
  Write-Host '[X] install.ps1 not found in the downloaded package.' -ForegroundColor Red
  return
}

$childArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $installer, '-Name', $Name)
if ($SkipInstall) { $childArgs += '-SkipInstall' }
if ($SkipAuth)    { $childArgs += '-SkipAuth' }
if ($DryRun)      { $childArgs += '-DryRun' }
& powershell.exe @childArgs
