# Codex × NotebookLM 一鍵安裝

讓 Codex 透過 MCP 串接 NotebookLM，把**簡報製作需求**直接送進 NotebookLM 產生。

安裝完成後，你可以在 Codex 裡直接說：「幫我用 NotebookLM 做一份簡報」。

---

## 一行安裝

**macOS / Linux**：打開「終端機」，貼上這一行，按 Enter：

```bash
curl -fsSL https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/install.sh | bash
```

**Windows**：打開「PowerShell」，貼上這一行，按 Enter：

```powershell
irm https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/install.ps1 | iex
```

> 想先看看會做什麼、但不真的安裝？在指令後面加上 `--dry-run`（Windows 為 `-DryRun`），詳見下方「進階選項」。

---

## 安裝前請先準備

| 項目 | 說明 |
|---|---|
| Codex CLI | 終端機輸入 `codex --version` 能看到版本號 |
| Python 3.11 以上 | 終端機輸入 `python3 --version`（Windows：`py -3 --version`）確認版本 |
| Google Chrome | 登入步驟會用到；Windows 請裝成「所有使用者」版本 |
| Google 帳號 | 能正常登入 [notebooklm.google.com](https://notebooklm.google.com) |

Windows 安裝 Python 時，請到 [python.org](https://www.python.org/downloads/) 下載，並勾選「Add python.exe to PATH」。

---

## 安裝過程會做什麼

腳本依序做五件事，每一步都會顯示結果：

1. **前置檢查**：Codex、Python 3.11 以上、Chrome
2. **安裝套件** `notebooklm-mcp-server`（先用 pip，失敗再改用 uv）
3. **登入 Google**：自動開啟一個專用的 Chrome 視窗，請在視窗中登入（5 分鐘內）
4. **註冊到 Codex**，並加上逾時設定（`startup_timeout_sec = 30`、`tool_timeout_sec = 300`）
5. **驗證**：確認 Codex 清單中已有 notebooklm

腳本可以**重複執行**：已安裝、已註冊、已有逾時設定的項目會自動略過。修改 Codex 設定檔之前，會先備份為 `config.toml.bak-notebooklm`。

---

## 安裝完成後

1. **完全關閉並重開 Codex**（MCP 只在 Codex 啟動時載入）
2. 在 Codex 輸入下面這句，測試連線：

   ```
   請列出我 NotebookLM 裡的所有筆記本。
   ```

   有列出筆記本，或清單為空但沒有報錯，就代表成功。
3. 開始送簡報需求，請看 [使用教學](docs/使用教學.md)。

---

## 文件索引

| 文件 | 內容 |
|---|---|
| [docs/安裝說明-macOS.md](docs/安裝說明-macOS.md) | macOS / Linux 的逐步安裝說明（含手動安裝） |
| [docs/安裝說明-Windows.md](docs/安裝說明-Windows.md) | Windows 的逐步安裝說明（含手動安裝） |
| [docs/使用教學.md](docs/使用教學.md) | 如何在 Codex 裡送出簡報需求、可調整的參數、取回簡報 |
| [docs/疑難排解.md](docs/疑難排解.md) | 常見錯誤、重新登入、更新、解除安裝 |
| [docs/prompts.md](docs/prompts.md) | 指令包：可直接複製的終端機指令與 Codex 對話範本 |
| [docs/設定講義.pdf](docs/設定講義.pdf) | 完整教學講義（A4 列印版） |

---

## 進階選項

| 選項（macOS / Linux） | 選項（Windows） | 作用 |
|---|---|---|
| `--dry-run` | `-DryRun` | 只顯示會做什麼，不實際執行 |
| `--skip-auth` | `-SkipAuth` | 略過 Google 登入 |
| `--skip-install` | `-SkipInstall` | 略過套件安裝 |
| `--name 名稱` | `-Name 名稱` | 在 Codex 註冊的名稱（預設 `notebooklm`） |

使用一行安裝時，要把選項傳進去：

```bash
curl -fsSL https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/install.sh | bash -s -- --dry-run
```

也可以先下載再執行：

```bash
git clone https://github.com/jyuli780-rgb/notebk-cx-mcp.git
cd notebk-cx-mcp
./install.sh            # Windows：雙擊 install.cmd
```

---

## 專案內容

| 檔案 | 說明 |
|---|---|
| `install.sh` | macOS / Linux 安裝腳本（在 Windows 的 Git Bash 執行時，會自動轉交給 `install.ps1`） |
| `install.ps1` | Windows 安裝腳本 |
| `install.cmd` | Windows 雙擊入口 |
| `scripts/helper.py` | 兩個系統共用的小工具（找執行檔位置、補逾時設定） |

---

## 安全說明

- 腳本**不使用 sudo、也不需要系統管理員權限**，只會修改 Codex 設定檔 `config.toml`。
- 登入憑證存放在 `~/.notebooklm-mcp/auth.json`（Windows：`%USERPROFILE%\.notebooklm-mcp\auth.json`），**等同你的 Google 登入憑證**，請勿外傳、勿上傳雲端、勿截圖分享。本專案不含任何憑證。
- 加入 NotebookLM 筆記本的資料會上傳到 Google，機密內容請先評估。
- 建議使用專用或次要的 Google 帳號。
- 這是**非官方**串接（借用你登入 Google 的狀態操作 NotebookLM），NotebookLM 改版時可能暫時失效，需等套件更新。
- 想在執行前確認腳本內容，可先到 [install.sh](install.sh)、[install.ps1](install.ps1) 閱讀原始碼。

## 重要提醒：請用對的 MCP

GitHub 上有兩個都叫 `notebooklm-mcp` 的專案，**功能不同，請勿混用**：

| | 本專案使用的 | 另一個同名專案 |
|---|---|---|
| 套件 | `notebooklm-mcp-server`（Python，作者 Jacob Ben-David） | `notebooklm-mcp`（Node.js，PleasePrompto/notebooklm-mcp） |
| 產生簡報 | **可以** | 不行（v2.0.0 尚未支援） |

兩者的執行檔名稱相同，同時安裝可能撞名。要送出簡報需求，請只使用本專案的版本。
