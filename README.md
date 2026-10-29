# Codex × NotebookLM 一鍵安裝

讓 Codex 透過 MCP 串接 NotebookLM，把簡報製作需求直接送進 NotebookLM 產生。

## 一鍵安裝

先下載本 repo：

```bash
git clone （本 repo 的網址） codex-notebooklm-setup
cd codex-notebooklm-setup
```

| 你的系統 | 執行方式 |
|---|---|
| macOS / Linux | `./install.sh` |
| Windows | 在檔案總管**雙擊 `install.cmd`**；或在 PowerShell 執行 `powershell -ExecutionPolicy Bypass -File .\install.ps1` |
| Windows（Git Bash） | `./install.sh`，會自動偵測並轉交給 `install.ps1` |

系統需求：已安裝 Codex CLI、Python 3.11 以上、Google Chrome。Windows 請從 python.org 安裝 Python 並勾選「Add python.exe to PATH」，Chrome 請裝成「所有使用者」版本（登入工具只認 `C:\Program Files\Google\Chrome\Application\chrome.exe`）。

腳本會依序做五件事：

1. 前置檢查：Codex、Python 3.11 以上、Chrome
2. 安裝 `notebooklm-mcp-server`（先用 pip，失敗再改用 uv）
3. 開啟專用 Chrome 視窗，讓你登入 Google
4. 註冊到 Codex，並加上逾時設定
5. 驗證

跑完後**重開 Codex**，輸入「請列出我 NotebookLM 裡的所有筆記本。」測試。

## 選項

| 選項 | 作用 |
|---|---|
| `--dry-run`（Windows：`-DryRun`） | 只顯示會做什麼，不實際執行 |
| `--skip-auth`（`-SkipAuth`） | 略過 Google 登入 |
| `--skip-install`（`-SkipInstall`） | 略過套件安裝 |
| `--name 名稱`（`-Name 名稱`） | 在 Codex 註冊的名稱（預設 notebooklm） |

可重複執行：已安裝、已註冊、已有逾時設定的項目會自動略過。

## 內容

- `install.sh`：macOS / Linux 安裝腳本（在 Windows Git Bash 會自動轉交 install.ps1）
- `install.ps1`、`install.cmd`：Windows 安裝腳本與雙擊入口
- `scripts/helper.py`：兩個系統共用的小工具
- `docs/設定講義.pdf`：完整教學講義（10 頁 A4）
- `docs/prompts.md`：指令包（終端機指令與 Codex 對話範本）

## 安全說明

- 腳本不使用 sudo／系統管理員權限，只修改 `~/.codex/config.toml`（Windows 為 `%USERPROFILE%\\.codex\\config.toml`）（修改前自動備份為 `config.toml.bak-notebooklm`）。
- 登入憑證存在 `~/.notebooklm-mcp/auth.json`，等同你的 Google 登入憑證，請勿外傳。本 repo 不含任何憑證。
- 這是非官方串接，NotebookLM 改版時可能暫時失效。
- 只支援 Python 版 `notebooklm-mcp-server`。GitHub 上同名的 Node 版（PleasePrompto/notebooklm-mcp）目前不支援簡報，請勿混用。
