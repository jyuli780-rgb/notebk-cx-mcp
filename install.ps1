#Requires -Version 5.1
<#
  Codex x NotebookLM MCP 一鍵安裝（Windows）
  做的事：前置檢查 -> 安裝 notebooklm-mcp-server -> 登入 Google -> 註冊到 Codex -> 加逾時設定 -> 驗證
  不需要系統管理員權限，不會讀取或上傳你的憑證內容。
  用法：雙擊 install.cmd，或  powershell -ExecutionPolicy Bypass -File .\install.ps1 [-DryRun] [-SkipAuth] [-SkipInstall] [-Name 名稱]
#>
[CmdletBinding()]
param(
  [string]$Name = 'notebooklm',
  [switch]$SkipInstall,
  [switch]$SkipAuth,
  [switch]$DryRun
)
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}
$env:PYTHONUTF8 = '1'
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path
$Helper = Join-Path $Here 'scripts\helper.py'

function Say($m)  { Write-Host ''; Write-Host ">> $m" -ForegroundColor Cyan }
function Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Warn($m) { Write-Host "  [!] $m" -ForegroundColor Yellow }
function Die($m)  { Write-Host "  [X] $m" -ForegroundColor Red; exit 1 }

# ---------- 1. 前置檢查 ----------
Say '1/5 前置檢查'
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) { Die '找不到 codex 指令，請先安裝 Codex CLI。' }
Ok ("Codex：" + ((& codex --version) | Select-Object -First 1))

$PyExe = $null; $PyPre = @()
$candidates = @(
  @{ Exe = 'py';      Pre = @('-3') },
  @{ Exe = 'python';  Pre = @() },
  @{ Exe = 'python3'; Pre = @() }
)
foreach ($c in $candidates) {
  if (-not (Get-Command $c.Exe -ErrorAction SilentlyContinue)) { continue }
  try {
    $out = & $c.Exe @($c.Pre) -c 'import sys; print(1 if sys.version_info >= (3, 11) else 0)' 2>$null
    if ("$out".Trim() -eq '1') { $PyExe = $c.Exe; $PyPre = @($c.Pre); break }
  } catch { }
}
if (-not $PyExe) { Die '需要 Python 3.11 以上。請到 python.org 安裝，並勾選「Add python.exe to PATH」。' }
Ok ("Python：" + ((& $PyExe @PyPre --version) | Select-Object -First 1))

$Chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path $Chrome)) {
  Warn "找不到 $Chrome 。登入工具只認這個位置，請安裝 Google Chrome（為所有使用者安裝）。"
  Warn '若仍無法開啟登入視窗，請找講師協助改用手動 Cookie 匯入（notebooklm-mcp-auth --file）。'
}

function Find-Bin([string]$n) {
  $c = Get-Command $n -ErrorAction SilentlyContinue | Select-Object -First 1
  if ($c) { return $c.Source }
  $dirs = (& $PyExe @PyPre $Helper bindirs 2>$null)
  foreach ($d in ("$dirs".Trim() -split ';')) {
    if ($d) { $p = Join-Path $d "$n.exe"; if (Test-Path $p) { return $p } }
  }
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    $ud = (& uv tool dir --bin 2>$null)
    if ($ud) { $p = Join-Path "$ud".Trim() "$n.exe"; if (Test-Path $p) { return $p } }
  }
  return $null
}

# ---------- 2. 安裝 ----------
Say '2/5 安裝 notebooklm-mcp-server'
$Bin = Find-Bin 'notebooklm-mcp'; $AuthBin = Find-Bin 'notebooklm-mcp-auth'
if ($Bin -and $AuthBin) {
  Ok "已安裝：$Bin"
} elseif ($SkipInstall) {
  Die '指定了 -SkipInstall，但找不到 notebooklm-mcp。'
} else {
  $done = $false
  if ($DryRun) {
    Write-Host "  [dry-run] $PyExe $($PyPre -join ' ') -m pip install notebooklm-mcp-server"; $done = $true
  } else {
    & $PyExe @PyPre -m pip install notebooklm-mcp-server
    $done = ($LASTEXITCODE -eq 0)
  }
  if (-not $done) {
    if (Get-Command uv -ErrorAction SilentlyContinue) {
      Warn 'pip 安裝失敗，改用 uv。'
      & uv tool install notebooklm-mcp-server
      if ($LASTEXITCODE -ne 0) { Die 'uv 安裝也失敗，請見講義排錯表。' }
    } else {
      Die 'pip 安裝失敗，且找不到 uv。請先安裝 uv（https://docs.astral.sh/uv/）後重跑。'
    }
  }
  $Bin = Find-Bin 'notebooklm-mcp'; $AuthBin = Find-Bin 'notebooklm-mcp-auth'
}
if ($DryRun) {
  if (-not $Bin) { $Bin = '<notebooklm-mcp 路徑>' }
  if (-not $AuthBin) { $AuthBin = '<notebooklm-mcp-auth 路徑>' }
}
if (-not $Bin -or -not $AuthBin) { Die '安裝後仍找不到 notebooklm-mcp，請見講義 4-3 排錯表。' }
Ok "執行檔：$Bin"

# ---------- 3. 登入 ----------
Say '3/5 登入 Google'
function Invoke-Auth {
  if ($DryRun) { Write-Host "  [dry-run] $AuthBin"; return }
  & $AuthBin
  if ($LASTEXITCODE -ne 0) { Die '登入未完成，請見講義 2-3「登入沒成功？」。' }
}
$AuthJson = Join-Path $HOME '.notebooklm-mcp\auth.json'
if ($SkipAuth) {
  Warn '已略過登入（-SkipAuth）。'
} elseif (Test-Path $AuthJson) {
  $ans = Read-Host '  已有登入憑證，要重新登入嗎？[y/N]'
  if ($ans -match '^[Yy]') { Invoke-Auth } else { Ok '沿用既有憑證' }
} else {
  Write-Host '  即將開啟專用 Chrome 視窗，請在視窗中登入 Google（5 分鐘內）。'
  Invoke-Auth
}

# ---------- 4. 註冊到 Codex ----------
Say '4/5 註冊到 Codex'
function Test-Registered {
  $o = & codex mcp list 2>$null
  foreach ($l in $o) { if ((("$l").Trim() -split '\s+')[0] -eq $Name) { return $true } }
  return $false
}
if (Test-Registered) {
  Ok "Codex 已有名為 $Name 的 MCP，略過註冊。"
} elseif ($DryRun) {
  Write-Host "  [dry-run] codex mcp add $Name -- $Bin"
} else {
  & codex mcp add $Name -- $Bin
  if ($LASTEXITCODE -ne 0) { Die 'codex mcp add 失敗。' }
}

$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME '.codex' }
$Cfg = Join-Path $CodexHome 'config.toml'
if ((-not $DryRun) -and (Test-Path $Cfg)) {
  $bak = "$Cfg.bak-notebooklm"
  if (-not (Test-Path $bak)) { Copy-Item $Cfg $bak }
  & $PyExe @PyPre $Helper timeouts $Cfg $Name
}

# ---------- 5. 驗證 ----------
Say '5/5 驗證'
if ($DryRun) {
  Warn 'dry-run 不做驗證。'
} elseif (Test-Registered) {
  Ok "Codex 已註冊 $Name"
} else {
  Die "Codex 清單中沒有 $Name ，請執行 codex mcp list 檢查。"
}

Write-Host ''
Write-Host '完成。接下來：' -ForegroundColor Green
Write-Host '  1. 完全關閉並重開 Codex（MCP 只在啟動時載入）'
Write-Host '  2. 在 Codex 輸入：請列出我 NotebookLM 裡的所有筆記本。'
Write-Host '  3. 成功後，參考 docs\prompts.md 送出簡報需求'
