# 安裝說明：Windows

> ⚠️ **注意：** Windows 版安裝腳本目前尚未在真實的 Windows 電腦上完整驗證。若遇到問題，請回報並附上 PowerShell 顯示的訊息。

最快的方式是回到 [README](../README.md) 貼上一行安裝指令。本文件說明**每一步在做什麼**，以及不使用腳本時如何**手動安裝**。

以下指令都在「PowerShell」執行（開始選單搜尋 PowerShell）。

---

## 一、前置檢查

```powershell
codex --version
```
```powershell
py -3 --version
```

- Codex 要能印出版本號。
- Python 必須是 **3.11 以上**。尚未安裝請到 <https://www.python.org/downloads/> 下載，安裝時務必勾選「**Add python.exe to PATH**」。
- 需要 Google Chrome，且請安裝成「**所有使用者**」版本。登入工具只會尋找 `C:\Program Files\Google\Chrome\Application\chrome.exe`，若 Chrome 裝在個人資料夾，登入視窗可能無法開啟。

---

## 二、用一行指令安裝（推薦）

```powershell
irm https://raw.githubusercontent.com/jyuli780-rgb/notebk-cx-mcp/main/install.ps1 | iex
```

跑完請直接跳到「六、重開 Codex 並測試」。

登入 Google 時，PowerShell 會顯示 `NOT LOGGED IN`，同時彈出一個專用的 Chrome 視窗。請在那個視窗登入你的 Google 帳號，直到看見 NotebookLM 首頁。出現 `SUCCESS`、視窗自動關閉，就代表登入完成。

**另一種方式：** 先 clone 或下載本專案，在檔案總管**雙擊 `install.cmd`**。

---

## 三、手動安裝（不使用一行指令時）

### 步驟 1：安裝套件

```powershell
py -3 -m pip install notebooklm-mcp-server
```

若失敗且你已安裝 uv，可改用：

```powershell
uv tool install notebooklm-mcp-server
```

### 步驟 2：找出指令位置

```powershell
where.exe notebooklm-mcp
```

會印出完整路徑（結尾是 `notebooklm-mcp.exe`），請記下來。若找不到，執行下面指令查出 pip 安裝資料夾，再在後面接上 `\notebooklm-mcp.exe`：

```powershell
py -3 -c "import sysconfig;print(sysconfig.get_path('scripts'))"
```

若沒有，也可以試試使用者安裝資料夾：

```powershell
py -3 -c "import site,os;print(os.path.join(site.getuserbase(),'Scripts'))"
```

### 步驟 3：登入 Google

```powershell
notebooklm-mcp-auth
```

（若提示找不到指令，請改用步驟 2 找到的資料夾，把指令換成該資料夾下的 `notebooklm-mcp-auth.exe` 完整路徑。）

會自動開啟專用 Chrome 視窗。請在 5 分鐘內登入，出現 `SUCCESS` 即完成。登入憑證存在 `%USERPROFILE%\.notebooklm-mcp\auth.json`。

### 步驟 4：註冊到 Codex

```powershell
codex mcp add notebooklm -- (Get-Command notebooklm-mcp).Source
```

若 `Get-Command` 找不到，直接寫完整路徑：

```powershell
codex mcp add notebooklm -- "C:\完整路徑\notebooklm-mcp.exe"
```

### 步驟 5：加上逾時設定（建議）

用記事本打開 `%USERPROFILE%\.codex\config.toml`，找到（或新增）這一段：

```toml
[mcp_servers.notebooklm]
command = "（步驟 2 的完整路徑）"
startup_timeout_sec = 30
tool_timeout_sec = 300
```

### 步驟 6：確認註冊成功

```powershell
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

---

## Windows 常見狀況

| 狀況 | 處理 |
|---|---|
| PowerShell 說「禁止執行指令碼」 | 使用上面的 `irm ... \| iex` 一行安裝（不受影響），或雙擊 `install.cmd` |
| `py` 或 `python` 找不到 | 重新安裝 Python，並勾選「Add python.exe to PATH」；裝好後重新開啟 PowerShell |
| 輸入 `python` 卻跳出 Microsoft Store | 這是 Windows 的假捷徑，請改用 `py -3`，或安裝真正的 Python |
| 登入視窗打不開 | 確認 Chrome 安裝在 `C:\Program Files\Google\Chrome\Application\`；若不是，請重新安裝為「所有使用者」版本 |
