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
