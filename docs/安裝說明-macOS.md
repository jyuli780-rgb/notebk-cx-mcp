# 安裝說明：macOS / Linux

最快的方式是回到 [README](../README.md) 貼上一行安裝指令。本文件說明**每一步在做什麼**，以及不使用腳本時如何**手動安裝**。

以下指令都在「終端機」執行。

---

## 一、前置檢查

```bash
codex --version
```
```bash
python3 --version
```

- Codex 要能印出版本號。
- Python 必須是 **3.11 以上**。
- 另外請確認已安裝 Google Chrome（在「應用程式」資料夾）。

---

## 二、用一行指令安裝（推薦）

```bash
curl -fsSL https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/install.sh | bash
```

跑完請直接跳到「六、重開 Codex 並測試」。

登入 Google 時，終端機會顯示 `NOT LOGGED IN`，同時彈出一個專用的 Chrome 視窗。請在那個視窗登入你的 Google 帳號，直到看見 NotebookLM 首頁。終端機出現 `SUCCESS`、視窗自動關閉，就代表登入完成。

---

## 三、手動安裝（不使用一行指令時）

### 步驟 1：安裝套件

```bash
python3 -m pip install notebooklm-mcp-server
```

如果出現 `externally-managed-environment` 錯誤（Homebrew 版 Python 的保護機制），改用 uv：

```bash
uv tool install notebooklm-mcp-server
```

（需要先安裝 uv，可參考 <https://docs.astral.sh/uv/>。）

### 步驟 2：確認指令存在

```bash
which notebooklm-mcp
```

會印出一個完整路徑，請記下來。如果沒有輸出，執行下面指令找出 pip 安裝資料夾，再在後面接上 `/notebooklm-mcp`，就是完整路徑：

```bash
python3 -c "import sysconfig;print(sysconfig.get_path('scripts'))"
```

### 步驟 3：登入 Google

```bash
notebooklm-mcp-auth
```

會自動開啟專用 Chrome 視窗（不影響你平常使用的 Chrome）。請在 5 分鐘內登入，出現 `SUCCESS` 即完成。

登入憑證會存在 `~/.notebooklm-mcp/auth.json`。只有第一次需要登入，憑證過期時再重跑一次即可。

### 步驟 4：註冊到 Codex

```bash
codex mcp add notebooklm -- $(which notebooklm-mcp)
```

### 步驟 5：加上逾時設定（建議）

產生簡報要等一陣子，請用文字編輯器打開 `~/.codex/config.toml`，找到（或新增）這一段：

```toml
[mcp_servers.notebooklm]
command = "（步驟 2 印出的完整路徑）"
startup_timeout_sec = 30
tool_timeout_sec = 300
```

### 步驟 6：確認註冊成功

```bash
codex mcp list
```

清單中要看到 `notebooklm`，狀態為 `enabled`。

---

## 六、重開 Codex 並測試

完全關閉再重開 Codex，輸入：

```
請列出我 NotebookLM 裡的所有筆記本。
```

有列出筆記本，或清單為空但沒有報錯，就代表成功。接著請看 [使用教學](使用教學.md)。

遇到問題請看 [疑難排解](疑難排解.md)。
