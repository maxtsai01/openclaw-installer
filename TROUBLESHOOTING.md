# 🦞 OpenClaw 安裝問題排除手冊

> 給老師用的：學員安裝時可能遇到的**所有問題**與解法

---

## 🪟 Windows 問題

### W1. PowerShell 被封鎖 / 跑不了腳本
**症狀：** `無法載入檔案，因為這個系統上已停用指令碼執行`
**原因：** Windows 預設禁止執行 .ps1 腳本
**解法：**
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```
然後再跑安裝指令。

### W2. 紅字「無法辨識為 Cmdlet」/ 指令找不到
**症狀：** `irm 無法辨識` 或 `Invoke-WebRequest 無法辨識`
**原因：** 開的是 CMD 不是 PowerShell
**解法：** 關掉 CMD，搜尋「PowerShell」→ 右鍵「以系統管理員身份執行」

### W3. 防毒軟體擋住下載
**症狀：** 下載中途失敗，或下載完檔案消失
**原因：** Norton/McAfee/小紅傘/360 把 node.zip 當威脅
**解法：** 暫時關閉防毒軟體 → 安裝完再開。或把 `C:\Users\<你>\openclaw\` 加白名單

### W4. Windows Defender 防火牆彈窗
**症狀：** 跳出「Windows 安全性警訊 — 允許 node.exe 通過防火牆？」
**原因：** Node.js 要開 port 18789 讓瀏覽器連
**解法：** 按「允許存取」（打勾「私人網路」就好）
**沒按到？** → 控制台 → Windows Defender 防火牆 → 允許應用程式通過 → 找 node.exe → 打勾

### W5. 公司電腦 / 沒有管理員權限
**症狀：** `存取被拒` 或 `Access Denied`
**原因：** 公司 IT 鎖了安裝權限
**解法 A：** 腳本已改裝在 `%USERPROFILE%\openclaw\`（使用者資料夾），通常不需要管理員
**解法 B：** 如果還是不行 → 請 IT 開權限，或用自己的電腦

### W6. 中文使用者名稱
**症狀：** Gateway 啟動後 config 讀取失敗
**原因：** 使用者名稱有中文（如 C:\Users\蔡宇軒\）
**解法：** 腳本已用正斜線路徑處理。如果還是有問題：
1. 開 `%USERPROFILE%\.openclaw\openclaw.json`
2. 把所有 `\` 換成 `/`
3. 確保是 UTF-8 無 BOM 編碼

### W7. 磁碟空間不足
**症狀：** npm install 到一半報錯
**原因：** 需要約 500MB 空間（Node 70MB + OpenClaw 400MB）
**解法：** 清理磁碟空間，或改裝到 D 槽：
```powershell
$InstallDir = "D:\openclaw"  # 改這行後重跑
```

### W8. 網路太慢 / 公司代理
**症狀：** 下載 Node.js 超時，或 npm install 卡住
**原因：** 公司 proxy、VPN、或網路太慢
**解法 A：** 手機開熱點
**解法 B：** 老師提前下載好 node.zip + openclaw npm 離線包，USB 發給學員
**解法 C：** 設 npm proxy：
```powershell
$env:HTTP_PROXY = "http://proxy.company.com:8080"
$env:HTTPS_PROXY = "http://proxy.company.com:8080"
```

### W9. npm install 報紅字但實際裝好了
**症狀：** 一堆 WARN 紅字，看起來像失敗
**原因：** npm 的 WARN 不是 ERROR，只是提醒
**解法：** 看最後一行有沒有 `added xxx packages`。腳本會檢查 `dist\index.js` 是否存在

### W10. Port 18789 被佔用
**症狀：** Dashboard 打開空白 / 連不上
**原因：** 之前的 node 進程沒關乾淨，或其他軟體用了這個 port
**解法：** 腳本已自動處理。手動修：
```powershell
Get-NetTCPConnection -LocalPort 18789 | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }
```

### W11. Windows S 模式
**症狀：** 完全無法執行 PowerShell 腳本
**原因：** Windows S 模式只允許 Microsoft Store 的 app
**解法：** 設定 → 更新與安全 → 啟用 → 切換到 Windows Home/Pro（免費，不可逆）

### W12. ARM 架構 Windows（Surface Pro X）
**症狀：** node.exe 跑起來特別慢
**原因：** 我們下載的是 x64 版，ARM 要靠模擬器跑
**解法：** 能用，但會慢一點。建議改下載 ARM 版 Node：
```
https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-arm64.zip
```

### W13. 重複執行安裝腳本
**症狀：** 第二次跑出現各種錯誤
**原因：** 上次裝到一半的殘留
**解法：** 腳本已處理（每步都先檢查是否已存在）。如果還有問題，清掉重來：
```powershell
Remove-Item -Recurse -Force "$env:USERPROFILE\openclaw"
Remove-Item -Recurse -Force "$env:USERPROFILE\.openclaw"
```

---

## 🍎 Mac 問題

### M1. 要求安裝 Xcode Command Line Tools
**症狀：** 跳出彈窗「需要安裝 Command Line Developer Tools」
**原因：** Homebrew 需要 git/gcc 等基本工具
**解法：** 按「安裝」→ 等幾分鐘 → 安裝完腳本會繼續

### M2. 密碼輸入沒反應
**症狀：** 叫你輸密碼，但打字什麼都沒顯示
**原因：** macOS 安全設計，密碼輸入不會顯示任何字元
**解法：** 正常打完密碼 → 按 Enter。告訴學員：「密碼是隱形的，打完按 Enter 就好」

### M3. Homebrew 安裝超久
**症狀：** 停在 Homebrew 安裝好幾分鐘不動
**原因：** 要下載 Xcode CLT（約 500MB）+ Homebrew 本體
**解法：** 等。通常 5-10 分鐘。如果真的太久 → 手機熱點試試

### M4. brew: command not found（M1/M2/M3 Mac）
**症狀：** 安裝完 Homebrew 但 `brew` 指令找不到
**原因：** Apple Silicon Mac 的 Homebrew 裝在 `/opt/homebrew/`，PATH 沒更新
**解法：** 腳本已處理。手動修：
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### M5. npm install 需要 sudo
**症狀：** `EACCES: permission denied`
**原因：** npm 全域安裝需要寫入 /usr/local/ 或 /opt/homebrew/
**解法：** 腳本已自動 fallback 到 sudo。手動：
```bash
sudo npm install -g openclaw
```

### M6. 已有舊版 Node.js
**症狀：** 安裝成功但 OpenClaw 跑起來怪怪的
**原因：** 系統上有 nvm 裝的其他版本 Node
**解法：** 確認用的是對的版本：
```bash
node -v  # 應該要 v22.x
```
如果不是：
```bash
nvm use 22 2>/dev/null || brew install node@22
```

### M7. macOS Gatekeeper 擋住
**症狀：** 「無法打開，因為 Apple 無法驗證」
**原因：** macOS 安全機制擋非 App Store 的軟體
**解法：** 通常不會遇到（我們不裝 .app）。如果遇到：
系統偏好設定 → 隱私與安全 → 「還是打開」

### M8. curl | bash 後 Token 輸入沒跳出來
**症狀：** 直接跳到啟動，沒有問 Token
**原因：** pipe 模式 stdin 被吃掉，read 指令讀不到使用者輸入
**解法：** v3 已把 Token 設定改到 Dashboard 裡面做，不在終端機問了

---

## 🌐 兩個平台共通問題

### C1. Dashboard 打開但 AI 不回話
**症狀：** 打字送出後沒反應，或顯示錯誤
**原因：** 還沒設定 AI Token
**解法：** 在 Dashboard 裡面設定 → 貼上 Anthropic API Token

### C2. 不知道怎麼拿 Token
**解法：** 老師投影操作：
1. 去 https://console.anthropic.com
2. 註冊/登入
3. API Keys → Create Key
4. 複製 key → 貼到 Dashboard

**或者：** 老師統一提供共用 Token（注意額度）

### C3. Dashboard 顯示但很慢
**原因：** Gateway 第一次啟動需要初始化
**解法：** 等 10-15 秒。重新整理瀏覽器

### C4. 瀏覽器沒自動打開
**解法：** 手動打開瀏覽器，輸入 `http://127.0.0.1:18789`

### C5. 想要重新來過
**Windows：**
```powershell
# 刪掉全部重裝
Remove-Item -Recurse -Force "$env:USERPROFILE\openclaw"
Remove-Item -Recurse -Force "$env:USERPROFILE\.openclaw"
# 重跑安裝腳本
```

**Mac：**
```bash
rm -rf ~/openclaw ~/.openclaw
# 重跑安裝腳本
```

---

## 📋 老師上課前 Checklist

- [ ] 確認教室有穩定 WiFi
- [ ] 準備手機熱點備用
- [ ] 準備 2-3 個 Anthropic API Token（學員用）
- [ ] 準備 USB 隨身碟（裝 node.zip 離線備用）
- [ ] 測試安裝腳本在乾淨 Windows + Mac 各跑一次
- [ ] 印出學員指令卡（Windows 一張、Mac 一張）
- [ ] 提前問學員：Windows/Mac？自己電腦還是公司的？

---

## 🎯 學員指令卡（印出來發）

### Windows 學員
```
1. 按鍵盤 Win 鍵 → 搜尋「PowerShell」
2. 右鍵 → 以系統管理員身份執行
3. 貼上這行指令（右鍵 = 貼上）：

Invoke-WebRequest -Uri "https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.ps1" -OutFile "$env:TEMP\install-openclaw.ps1"; & "$env:TEMP\install-openclaw.ps1"

4. 等待 3-5 分鐘
5. 瀏覽器打開 = 成功！
```

### Mac 學員
```
1. 按 Cmd+Space → 搜尋「終端機」→ 打開
2. 貼上這行指令（Cmd+V）：

curl -fsSL https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.sh | bash

3. 可能需要輸入電腦密碼（密碼不會顯示，正常打完按 Enter）
4. 等待 3-5 分鐘
5. 瀏覽器打開 = 成功！
```

---

## 🔧 升級/維護期問題（進階）

> 這一段不是給學員看的，是給已經跑很久的 OpenClaw（升級過、被升級過、加裝過 plugin、被 watchdog 戳過）的維運參考。所有問題都來自真實事故。

### U1. Discord 完全不回應，但 Gateway 看起來活著（最常見）

**症狀：**
- `openclaw gateway status` 顯示 **Listening: 0.0.0.0:18789** ✅
- `openclaw doctor` 報告 **Plugins Loaded: 40, Errors: 0** ✅
- 但 Discord 上不管 @ 或私訊都沒任何反應
- 已經沉默幾小時甚至幾天

**診斷：**
查 Gateway 真正的 log（不是 stdout/stderr）：

```powershell
# Windows
Get-Content C:\tmp\openclaw\openclaw-$(Get-Date -Format yyyy-MM-dd).log -Tail 100 | Select-String "discord"
```

```bash
# Mac/Linux
tail -100 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i discord
```

**如果看到：**
```
[plugins] discord failed to load: Error: Cannot find module '@buape/carbon'
[plugins] failed to load plugin: (plugin=discord, source=...extensions/discord/index.js)
```

**根因：** Discord extension 的 peer dependency `@buape/carbon` 沒裝在 Gateway 實際使用的那個 `node_modules`。

**解法：**
```bash
cd <openclaw 安裝目錄>
npm install @buape/carbon
# 重啟 Gateway
openclaw gateway restart
```

**Windows 範例（Node 22 + 雙 nvm 環境，看 U2）：**
```cmd
D:\node-v22.14.0-win-x64\npm.cmd --prefix D:\node-v22.14.0-win-x64\node_modules\openclaw install @buape/carbon
openclaw gateway restart
```

**驗證：** 重啟後再查 log，應該看到：
```
[default] Discord Message Content Intent is limited; bots under 100 servers can use it without verification.
[default] starting provider (@<bot 名稱>)
```

---

### U2. 雙 Node 陷阱（doctor 說沒事，Gateway 卻在崩）

**症狀：**
- `openclaw doctor` 完全沒報錯
- `openclaw gateway status` 顯示正常
- 但 plugin 載入失敗（看 U1）
- log 裡同一時間段出現 **兩個不同的 `runtimeVersion`**

**診斷指令（Windows）：**
```powershell
Get-Content C:\tmp\openclaw\openclaw-$(Get-Date -Format yyyy-MM-dd).log -Tail 200 | Select-String '"runtimeVersion":"[^"]+"' | ForEach-Object { ($_ -match '"runtimeVersion":"([^"]+)"') | Out-Null; $matches[1] } | Sort-Object -Unique
```

**如果輸出有兩行不同版本（例如 `22.14.0` 和 `25.5.0`），就中招了。**

**根因：** 系統上裝了兩個不同 Node 版本：
- **Node A**（例如 `D:\node-v22.14.0-win-x64\`）— `gateway.cmd` 寫死跑這個
- **Node B**（例如 `C:\ProgramData\nvm\v25.5.0\`）— CLI / `openclaw doctor` 跑這個

兩邊各自有獨立的 `node_modules\openclaw`，**peer dep 也是分別管理的**。`doctor` 看的是 Node B，但 Gateway 跑的是 Node A — 所以 doctor 永遠檢查不出 Gateway 的真正問題。

**解法 A（最安全）：** 在 Node A 那邊也補裝缺的 plugin
```cmd
D:\node-v22.14.0-win-x64\npm.cmd --prefix D:\node-v22.14.0-win-x64\node_modules\openclaw install @buape/carbon
```

**解法 B（根本）：** 讓 `gateway.cmd` 改用 Node B（跟 CLI 統一）
```cmd
notepad C:\Users\<user>\.openclaw\gateway.cmd
```
把 `D:\node-v22.14.0-win-x64\node.exe` 改成 `C:\ProgramData\nvm\v25.5.0\node.exe`，存檔重啟 Gateway。

**怎麼判斷哪個 Node 該留：** 看 `node_modules\openclaw` 的版本是不是最新，看哪邊的 plugin 補得完整，新的留它。

---

### U3. Watchdog 誤殺 Gateway（SelfHeal 重複重啟）

**症狀：**
- `selfheal.log` 或 `self-rescue.log` 裡每 5-15 分鐘就出現一行 `Gateway process not found, starting...`
- 但其實 Gateway port 是有 listening 的
- 你手動啟動 Gateway 後，幾分鐘內就被砍掉重啟

**根因：** Watchdog 用 process name 偵測 Gateway 是否活著（`Get-Process node` 之類），但系統上同時跑了好幾個 node.exe（Rainbow VIP、其他工具、cron job…），watchdog 抓不到「我管的那一個」就認定 Gateway 死了。

**完全錯誤的偵測方式：**
```powershell
# ❌ 這樣會抓到所有 node 進程，誤判頻繁
if (-not (Get-Process node -ErrorAction SilentlyContinue)) { Restart-Gateway }
```

**正確的偵測方式（用 port + HTTP 健康檢查）：**
```powershell
# ✅ port 是 Gateway 真正的存活訊號
$listening = Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue
if (-not $listening) { Restart-Gateway; return }

# 進階：再確認 HTTP 端點有回應
try { Invoke-WebRequest http://127.0.0.1:18789/health -TimeoutSec 5 | Out-Null } 
catch { Restart-Gateway }
```

**緊急應對（先停亂跑的 watchdog）：**
```cmd
schtasks /change /tn "Emily-SelfHeal" /disable
schtasks /change /tn "Emily SelfRescue" /disable
```

**長期：** 重寫 watchdog 用 port-based 偵測，或改用 pm2 / nssm 之類的成熟 process supervisor。

---

### U4. gateway.cmd 缺少 log redirect（看不到啟動錯誤）

**症狀：**
- Gateway 啟動失敗，但 `gateway-stdout.log` / `gateway-stderr.log` 完全沒寫東西
- 這兩個檔案的 `LastWriteTime` 停在好幾天前

**根因：** schtask 啟動 `gateway.cmd` 時，沒用 `>` 把 stdout/stderr 接到檔案，所以所有早期啟動訊息（包括 fatal error）都直接被丟掉。

**修法：** 編輯 `~\.openclaw\gateway.cmd`（或 Mac/Linux 對應路徑），最後一行從：
```cmd
node "%OPENCLAW_DIST%\index.js" gateway --port %OPENCLAW_GATEWAY_PORT%
```
改成：
```cmd
node "%OPENCLAW_DIST%\index.js" gateway --port %OPENCLAW_GATEWAY_PORT% >> "%USERPROFILE%\.openclaw\gateway-stdout.log" 2>> "%USERPROFILE%\.openclaw\gateway-stderr.log"
```

**注意：** Gateway 內建檔案 log 在 `C:\tmp\openclaw\openclaw-YYYY-MM-DD.log`（Windows）或 `/tmp/openclaw/openclaw-YYYY-MM-DD.log`（Mac/Linux），有些版本會寫，有些不會寫。內建 log **不一定包含啟動最早的 stdout** — 所以 stdout/stderr redirect 還是要加。

---

### U5. Claude quota 燒光 — 設定 Gemini fallback

**症狀：**
```
FailoverError: LLM request rejected: 
You're out of extra usage. Add more at claude.ai/settings/usage and keep going.
All models failed (2):
  anthropic/claude-opus-4-6: ...out of extra usage...
  anthropic/claude-sonnet-4-6: ...out of extra usage...
Embedded agent failed before reply
```

**根因：** primary 和 fallback **全是同一家** Anthropic，quota 一掛就連環死。

**解法：** 加 Google Gemini 當 fallback，至少不會雙死。

**Step 1：拿 Gemini API key**
- https://aistudio.google.com/apikey
- 用 Google 帳號登入
- Create API key → 複製

**Step 2：寫進 `~/.openclaw/.env`**
```bash
GEMINI_API_KEY=AIzaSy...
GOOGLE_API_KEY=AIzaSy...   # 同一支 key 兩個變數，相容兩種讀法
```

**Step 3：改 `~/.openclaw/openclaw.json` 的 `agents.defaults.model`**
```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-2.5-flash",
        "fallbacks": [
          "anthropic/claude-opus-4-6",
          "anthropic/claude-sonnet-4-6"
        ]
      }
    }
  }
}
```

**驗證：**
```bash
openclaw gateway restart
tail -50 /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log | grep -i "agent model"
# 應該看到：agent model: google/gemini-2.5-flash
```

**省錢小技巧：** Gemini 2.5 Flash 免費 tier 每分鐘 30 次請求 + 每天 1500 次，個人 / 小團隊用通常夠。Pro 等級可付費升級。

**注意：** 不要把 Mac 跟其他機器用同一支 Gemini key（會搶 quota）。每台機器、每個 agent 用獨立的 Google 帳號 + 獨立 key 最乾淨。

---

### U6. JSON config schema 變嚴 — `Unrecognized key` 錯誤

**症狀：**
```
Invalid config at ~/.openclaw/openclaw.json:
  - meta: Unrecognized key: "lastTouchedBy"
Config invalid
Gateway aborted: config is invalid.
```

**根因：** 舊版 OpenClaw 對 unknown key 寬鬆，新版（2026.3.28+）改成嚴格 schema validation。任何手動加的非標準 key 都會被拒。

**解法 A：** `openclaw doctor --fix` 自動清

**解法 B：** 手動移除錯誤訊息裡指出的 key，重啟 Gateway

**保險做法：** 改 config 前一定先備份：
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup-$(date +%Y%m%d-%H%M%S)
```

---

## 📜 案例復盤：Emily 35 小時沉默事件（2026-04-08）

### 狀況
- **2026-04-06 ~23:00**：Emily（跑在 Windows desktop）最後一次在 Discord 正常回應
- **2026-04-07 全天**：Emily 完全沉默，Allison 多次 @ 都沒反應
- **2026-04-08 11:00**：Allison 呼叫 Max（跑在 Mac）「把 Emily 修復穩定」
- **2026-04-08 11:54**：Emily 復活，第一句回應老闆

**沉默總時長：約 35 小時。**

### 修復過程（Max 從 Mac 遠端 SSH 進 Windows 修）

1. **第 1 層誤判（quota 假象）**：
   gateway-stderr.log 裡看到 4/7 14:22 的 `out of extra usage` 錯誤，以為是 Anthropic quota 燒光。
   **真相：** 那是升級前最後幾筆訊息的錯誤，跟 4/8 沉默無關。但仍然當場修了 → 改 primary 為 Gemini 2.5 Flash + Anthropic 當 fallback（U5）。

2. **第 2 層誤判（watchdog 亂殺）**：
   發現 `Emily-SelfHeal` 和 `Emily SelfRescue` 兩個 schtask 各自每 5-15 分鐘亂殺亂啟 Gateway，pid 不停變。
   **真相：** 也是真實 bug（U3），但不是「為什麼 Discord 沉默」的根因。當場 disable 兩個 watchdog 清場。

3. **第 3 層誤判（log 找錯地方）**：
   `gateway-stdout.log` / `gateway-stderr.log` 兩個檔案 LastWriteTime 停在 24 小時前，以為 Gateway 連啟動都沒成功。
   **真相：** `gateway.cmd` 啟動指令沒有 redirect stdout/stderr（U4），所以 schtask 模式下這兩個檔案永遠是空的。Gateway 真正的 log 在 `C:\tmp\openclaw\openclaw-2026-04-08.log`。

4. **🎯 真正根因：Discord plugin 缺套件**
   找對 log 後 5 秒就看到：
   ```
   [plugins] discord failed to load: Error: Cannot find module '@buape/carbon'
   ```
   **OpenClaw 升級到 2026.3.28+ 後，discord extension 需要 peer dep `@buape/carbon`，但這個機器升級時沒自動裝。**

5. **第 4 層陷阱：雙 Node**
   要裝 `@buape/carbon` 時發現系統有兩個 Node：
   - `D:\node-v22.14.0-win-x64\` ← Gateway schtask 用這個（缺 carbon）
   - `C:\ProgramData\nvm\v25.5.0\` ← CLI / `doctor` 用這個（**有 carbon**）

   所以 `openclaw doctor` 一直回報「Plugins Errors: 0」，**因為 doctor 看的是 v25.5 那邊**。而真正的問題在 v22.14 的 openclaw 缺套件。

   **修：** 在 v22.14 那邊跑：
   ```cmd
   D:\node-v22.14.0-win-x64\npm.cmd --prefix D:\node-v22.14.0-win-x64\node_modules\openclaw install @buape/carbon
   ```
   → `added 274 packages` → 重啟 Gateway → Discord 復活。

### 教訓

1. **不要相信 `openclaw doctor` 在多 Node 環境的判斷** — 它只檢查 PATH 找到的那個 Node 的 openclaw
2. **`gateway.cmd` 一定要加 stdout/stderr redirect**（U4）— 沒 log 等於閉著眼修
3. **Gateway 真正的 log 在 `/tmp/openclaw/openclaw-YYYY-MM-DD.log`** — 不是 `gateway-stdout.log`
4. **Watchdog 一定要用 port-based 偵測**，不要用 process name（U3）
5. **Anthropic-only fallback 是地雷** — 永遠要有跨 provider fallback（U5）
6. **OpenClaw 升級後要跑兩件事**：
   - `openclaw doctor --fix`（補 schema 變更）
   - 在 Gateway 實際用的那個 Node 上跑 `npm install`（補 plugin peer deps）

### 新增的監控

- 加一個 Mac 端的遠端 health check：每 30 分鐘 ping 一下 Emily 的 Discord，若 1 小時內 0 回應就警報
- Watchdog 全面改 port-based
- gateway.cmd 加 stdout/stderr redirect
- 加 multi-provider fallback 到所有 agent

---
