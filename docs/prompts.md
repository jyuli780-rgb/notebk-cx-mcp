# Codex × NotebookLM 指令包

> 配合講義《Codex 串接 NotebookLM MCP 設定講義》使用。
> 使用方式：A 區貼到「終端機」；B 區貼到「Codex 對話框」。每個區塊獨立，一次貼一個。
> 本包只適用 Python 版 `notebooklm-mcp-server`（可產生簡報）。不要與 GitHub 上 PleasePrompto/notebooklm-mcp（Node 版，不支援簡報）混用。

---

## 0. 最快方式：一鍵安裝

```bash
./install.sh
```
（在本 repo 資料夾內執行。以下 A 區是同樣步驟的手動版。）

## A. 終端機指令（手動設定，依序執行）

### A1　前置檢查
```bash
codex --version
```
```bash
python3 --version
```
Python 需 3.11 以上。

### A2　安裝 NotebookLM MCP
```bash
python3 -m pip install notebooklm-mcp-server
```
若出現 `externally-managed-environment` 錯誤（Homebrew 版 Python 的保護機制），改用 uv：
```bash
uv tool install notebooklm-mcp-server
```

### A3　確認指令存在（會印出完整路徑，請記下來）
```bash
which notebooklm-mcp
```
沒有輸出時，找出 pip 安裝資料夾，後面接 `/notebooklm-mcp` 就是完整路徑：
```bash
python3 -c "import sysconfig;print(sysconfig.get_path('scripts'))"
```

### A4　登入 Google
```bash
notebooklm-mcp-auth
```
會自動開啟專用 Chrome 視窗。終端機顯示 NOT LOGGED IN 時，在視窗登入 Google（5 分鐘內）；出現 SUCCESS 且視窗自動關閉即完成。
若出現「profile is already in use」，關掉上次殘留的授權視窗再重跑；Chrome 啟動失敗則先完全關閉 Chrome 再重跑。

### A5　註冊到 Codex
```bash
codex mcp add notebooklm -- $(which notebooklm-mcp)
```

### A6　確認註冊成功（看到 notebooklm 且為 enabled）
```bash
codex mcp list
```

### A7　（建議）加上逾時設定
用編輯器打開 `~/.codex/config.toml`，找到或新增這一段（一鍵安裝會自動加）：
```toml
[mcp_servers.notebooklm]
command = "（A3 印出的完整路徑）"
startup_timeout_sec = 30
tool_timeout_sec = 300
```
改完後重開 Codex。

### A8　憑證過期時重新登入
```bash
notebooklm-mcp-auth
```

---

## B. Codex 對話指令（使用用，直接貼到 Codex）

### B1　連線測試（先做這個）
```
請列出我 NotebookLM 裡的所有筆記本。
```
有列出筆記本，或清單為空但沒報錯 → 成功。出現認證錯誤 → 做 A8。

### B2　簡報需求範本一：用網址當資料來源
```
請用 NotebookLM 幫我做一份簡報：
1. 建立新筆記本，名稱「（筆記本名稱）」。
2. 加入這個網址作為資料來源：（貼上網址）。
3. 語言用繁體中文，受眾是（受眾），重點放在（重點）。
4. 送出生成之前，先把設定唸給我確認。
```

### B3　簡報需求範本二：用我貼的文字當資料來源
```
請用 NotebookLM 幫我做一份簡報：
1. 建立新筆記本，名稱「（筆記本名稱）」。
2. 把下面這段文字加入筆記本當資料來源：
（貼上文字）
3. 語言用繁體中文，受眾是（受眾），重點放在（重點）。
4. 送出生成之前，先把設定唸給我確認。
```

### B4　簡報需求範本三：用既有筆記本
```
請列出我的筆記本。我選「（筆記本名稱）」，
用裡面所有資料幫我生成簡報，繁體中文，
受眾是（受眾），重點放在（重點）。
送出之前，先把設定唸給我確認。
```

### B5　指定簡報版型與長度
```
生成簡報時請用「講者版」（presenter_slides），長度用短版（short），
語言 zh-TW。
```
對照：詳細版 `detailed_deck`（自己閱讀）、講者版 `presenter_slides`（上台用）；長度 `short` 或 `default`。

### B6　確認送出
```
確認，請送出。
```

### B7　查詢簡報進度
```
請查詢剛剛那份簡報的產生狀態，完成後告訴我。
```
完成後到 notebooklm.google.com，打開該筆記本的 Studio 區預覽與下載（此 MCP 沒有簡報下載工具）。

### B8　資料太少時，請 NotebookLM 先找資料
```
請在筆記本「（筆記本名稱）」開始研究主題「（主題）」，
研究完成後告訴我，我確認後再匯入來源。
```

---

## C. 需求單（送出前自我檢查）

| 項目 | 我的內容 |
|---|---|
| 筆記本名稱 | |
| 資料來源（網址或文字，建議 2 份以上） | |
| 語言 | 繁體中文（zh-TW） |
| 受眾 | |
| 簡報重點 | |
| 版型 | 詳細版／講者版 |
| 長度 | 短版／標準 |

---

## D. 排錯速查

| 狀況 | 處理 |
|---|---|
| 認證錯誤 | 執行 A8 重新登入 |
| pip 安裝被擋 | 改用 A2 的 uv 指令 |
| Codex 看不到 notebooklm | 重開 Codex；執行 A6 檢查路徑 |
| 啟動逾時 | `startup_timeout_sec` 調到 60 |
| 簡報遲遲沒好 | 等 3 到 5 分鐘，再執行 B7 |
| 簡報變成英文 | 需求中註明繁體中文（zh-TW） |
| 內容空洞 | 多加資料來源，並在重點寫清楚受眾與場合 |

## E. 安全提醒

1. `~/.notebooklm-mcp/auth.json` 等同 Google 登入憑證，不要外傳、不要上雲端、不要截圖。
2. 加入筆記本的資料會上傳到 Google，機密內容請先評估。
3. 這是非官方串接，NotebookLM 改版時可能暫時失效。
4. 建議使用專用或次要 Google 帳號。
