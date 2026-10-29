#!/usr/bin/env bash
# Codex × NotebookLM MCP 一鍵安裝（macOS / Linux）
# 做的事：前置檢查 → 安裝 notebooklm-mcp-server → 登入 Google → 註冊到 Codex → 加逾時設定 → 驗證
# 不會用 sudo、不會讀取或上傳你的憑證內容。
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="notebooklm"; SKIP_INSTALL=0; SKIP_AUTH=0; DRY=0

# 在 Windows 的 Git Bash / MSYS / Cygwin 執行時，自動轉交給 install.ps1
case "$(uname -s 2>/dev/null)" in
  MINGW*|MSYS*|CYGWIN*)
    PSARGS=()
    while [ $# -gt 0 ]; do
      case "$1" in
        --dry-run) PSARGS+=(-DryRun); shift ;;
        --skip-auth) PSARGS+=(-SkipAuth); shift ;;
        --skip-install) PSARGS+=(-SkipInstall); shift ;;
        --name) PSARGS+=(-Name "${2:?--name 需要一個名稱}"); shift 2 ;;
        *) PSARGS+=("$1"); shift ;;
      esac
    done
    echo "偵測到 Windows，改用 install.ps1 ..."
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$DIR/install.ps1")" ${PSARGS[@]+"${PSARGS[@]}"}
    ;;
esac

usage() {
  cat <<'EOF'
用法：./install.sh [選項]
  --name 名稱       在 Codex 裡註冊的名稱（預設 notebooklm）
  --skip-install    不安裝套件（已安裝時用）
  --skip-auth       不做 Google 登入
  --dry-run         只顯示會做什麼，不實際執行
  -h, --help        顯示說明
EOF
}
while [ $# -gt 0 ]; do
  case "$1" in
    --name) NAME="${2:?--name 需要一個名稱}"; shift 2 ;;
    --skip-install) SKIP_INSTALL=1; shift ;;
    --skip-auth) SKIP_AUTH=1; shift ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知參數：$1"; usage; exit 1 ;;
  esac
done

say()  { printf '\n\033[1m▶ %s\033[0m\n' "$*"; }
ok()   { printf '  ✅ %s\n' "$*"; }
warn() { printf '  ⚠️  %s\n' "$*"; }
die()  { printf '  ❌ %s\n' "$*" >&2; exit 1; }
run()  { if [ "$DRY" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi; }

# ---------- 1. 前置檢查 ----------
say "1/5 前置檢查"
command -v codex >/dev/null 2>&1 || die "找不到 codex 指令，請先安裝 Codex CLI。"
ok "Codex：$(codex --version 2>&1 | head -1)"

PY=""
for c in python3 python3.14 python3.13 python3.12 python3.11; do
  if command -v "$c" >/dev/null 2>&1 && "$c" -c 'import sys; sys.exit(0 if sys.version_info >= (3, 11) else 1)' 2>/dev/null; then
    PY="$c"; break
  fi
done
[ -n "$PY" ] || die "需要 Python 3.11 以上，請先安裝（例如 brew install python）。"
ok "Python：$($PY --version 2>&1)"

if [ "$(uname)" = "Darwin" ] && [ ! -d "/Applications/Google Chrome.app" ]; then
  warn "找不到 Google Chrome，第 3 步登入需要它，請先安裝。"
fi

# 依序在 PATH、pip 腳本資料夾（含 --user）、uv 工具資料夾找執行檔
find_bin() {
  local b d x
  b="$(command -v "$1" 2>/dev/null || true)"
  if [ -n "$b" ]; then echo "$b"; return 0; fi
  d="$("$PY" "$DIR/scripts/helper.py" bindirs 2>/dev/null || true)"
  IFS=: read -ra dirs <<<"$d"
  for x in "${dirs[@]}"; do
    if [ -n "$x" ] && [ -x "$x/$1" ]; then echo "$x/$1"; return 0; fi
  done
  if command -v uv >/dev/null 2>&1; then
    d="$(uv tool dir --bin 2>/dev/null || true)"
    if [ -n "$d" ] && [ -x "$d/$1" ]; then echo "$d/$1"; return 0; fi
  fi
  return 0
}

# ---------- 2. 安裝 ----------
say "2/5 安裝 notebooklm-mcp-server"
BIN="$(find_bin notebooklm-mcp)"; AUTHBIN="$(find_bin notebooklm-mcp-auth)"
if [ -n "$BIN" ] && [ -n "$AUTHBIN" ]; then
  ok "已安裝：$BIN"
elif [ "$SKIP_INSTALL" = 1 ]; then
  die "指定了 --skip-install，但找不到 notebooklm-mcp。"
else
  if run "$PY" -m pip install notebooklm-mcp-server; then
    :
  elif command -v uv >/dev/null 2>&1; then
    warn "pip 安裝失敗（常見原因：Homebrew Python 的保護機制），改用 uv。"
    run uv tool install notebooklm-mcp-server
  else
    die "pip 安裝失敗，且找不到 uv。請先安裝 uv（brew install uv）後重跑本腳本。"
  fi
  BIN="$(find_bin notebooklm-mcp)"; AUTHBIN="$(find_bin notebooklm-mcp-auth)"
fi
if [ "$DRY" = 1 ]; then BIN="${BIN:-<notebooklm-mcp 路徑>}"; AUTHBIN="${AUTHBIN:-<notebooklm-mcp-auth 路徑>}"; fi
[ -n "$BIN" ] && [ -n "$AUTHBIN" ] || die "安裝後仍找不到 notebooklm-mcp，請見講義 4-3 排錯表。"
ok "執行檔：$BIN"

# ---------- 3. 登入 ----------
say "3/5 登入 Google"
AUTHJSON="$HOME/.notebooklm-mcp/auth.json"
if [ "$SKIP_AUTH" = 1 ]; then
  warn "已略過登入（--skip-auth）。"
elif [ -f "$AUTHJSON" ]; then
  ans=""
  read -r -p "  已有登入憑證，要重新登入嗎？[y/N] " ans </dev/tty 2>/dev/null || true
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    run "$AUTHBIN" || die "登入未完成，請見講義 2-3「登入沒成功？」。"
  else
    ok "沿用既有憑證"
  fi
else
  echo "  即將開啟專用 Chrome 視窗，請在視窗中登入 Google（5 分鐘內）。"
  run "$AUTHBIN" || die "登入未完成，請見講義 2-3「登入沒成功？」。"
fi

# ---------- 4. 註冊到 Codex ----------
say "4/5 註冊到 Codex"
if codex mcp list 2>/dev/null | awk '{print $1}' | grep -qx "$NAME"; then
  ok "Codex 已有名為 $NAME 的 MCP，略過註冊。"
else
  run codex mcp add "$NAME" -- "$BIN"
fi

CFG="${CODEX_HOME:-$HOME/.codex}/config.toml"
if [ "$DRY" = 0 ] && [ -f "$CFG" ]; then
  [ -f "$CFG.bak-notebooklm" ] || cp "$CFG" "$CFG.bak-notebooklm"
  "$PY" "$DIR/scripts/helper.py" timeouts "$CFG" "$NAME"
fi

# ---------- 5. 驗證 ----------
say "5/5 驗證"
if [ "$DRY" = 1 ]; then
  warn "dry-run 不做驗證。"
elif codex mcp list 2>/dev/null | awk '{print $1}' | grep -qx "$NAME"; then
  ok "Codex 已註冊 $NAME"
else
  die "Codex 清單中沒有 $NAME，請執行 codex mcp list 檢查。"
fi

cat <<EOF

🎉 完成。接下來：
  1. 完全關閉並重開 Codex（MCP 只在啟動時載入）
  2. 在 Codex 輸入：請列出我 NotebookLM 裡的所有筆記本。
  3. 成功後，參考 docs/prompts.md 送出簡報需求
EOF
