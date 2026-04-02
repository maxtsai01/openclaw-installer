# ============================================
# 🦞 OpenClaw 一鍵安裝（Windows 版）
# 用法：以系統管理員打開 PowerShell，貼上：
#   Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.ps1 | iex
# ============================================

$ErrorActionPreference = "Continue"
$NodeVersion = "22.14.0"
$NodeDir = "C:\openclaw\node"
$NodeZip = "$env:TEMP\node-openclaw.zip"
$NodeUrl = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"

Clear-Host
Write-Host ""
Write-Host "  🦞 OpenClaw 一鍵安裝 for Windows" -ForegroundColor Cyan
Write-Host "  =================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  全程自動，請耐心等待約 3-5 分鐘" -ForegroundColor Gray
Write-Host ""

# ======== Step 1: Node.js ========
Write-Host "📦 [1/5] 安裝 Node.js..." -ForegroundColor Yellow
if (Test-Path "$NodeDir\node.exe") {
    Write-Host "  ✅ Node.js 已存在，跳過" -ForegroundColor Green
} else {
    try {
        Write-Host "  ⬇️  下載中（約 30MB）..." -ForegroundColor Gray
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZip -UseBasicParsing
        
        Write-Host "  📂 解壓中..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path "C:\openclaw" -Force | Out-Null
        Expand-Archive -Path $NodeZip -DestinationPath "C:\openclaw\temp" -Force
        
        if (Test-Path $NodeDir) { Remove-Item $NodeDir -Recurse -Force }
        Move-Item "C:\openclaw\temp\node-v$NodeVersion-win-x64" $NodeDir -Force
        Remove-Item "C:\openclaw\temp" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $NodeZip -Force -ErrorAction SilentlyContinue
        
        Write-Host "  ✅ Node.js v$NodeVersion 安裝完成" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Node.js 下載失敗！請檢查網路連線" -ForegroundColor Red
        Write-Host "  錯誤：$($_.Exception.Message)" -ForegroundColor Red
        pause
        exit 1
    }
}
$env:PATH = "$NodeDir;$env:PATH"

# ======== Step 2: OpenClaw ========
Write-Host "📦 [2/5] 安裝 OpenClaw（約 2-3 分鐘）..." -ForegroundColor Yellow
$npmOutput = & "$NodeDir\npm.cmd" install -g openclaw --ignore-scripts 2>&1
$ocEntry = "$NodeDir\node_modules\openclaw\dist\index.js"

if (Test-Path $ocEntry) {
    Write-Host "  ✅ OpenClaw 安裝完成" -ForegroundColor Green
} else {
    Write-Host "  ❌ 安裝失敗！" -ForegroundColor Red
    Write-Host "  $npmOutput" -ForegroundColor Gray
    Write-Host "  請截圖給老師" -ForegroundColor Yellow
    pause
    exit 1
}

# ======== Step 3: 設定檔 ========
Write-Host "🔧 [3/5] 建立設定..." -ForegroundColor Yellow
$configDir = "$env:USERPROFILE\.openclaw"
$configFile = "$configDir\openclaw.json"
$agentDir = "$configDir\agents\main\agent"
$workspaceDir = "$configDir\workspace"
$authFile = "$agentDir\auth-profiles.json"

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null
New-Item -ItemType Directory -Path "$workspaceDir\memory" -Force | Out-Null

# 設定檔（只在不存在時建立）
if (-not (Test-Path $configFile)) {
    $wsEscaped = $workspaceDir -replace '\\', '\\'
    $adEscaped = $agentDir -replace '\\', '\\'
    $configJson = @"
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "auth": {
      "mode": "open"
    }
  },
  "agents": {
    "list": [
      {
        "id": "main",
        "name": "main",
        "workspace": "$wsEscaped",
        "agentDir": "$adEscaped",
        "model": "anthropic/claude-sonnet-4-6"
      }
    ]
  }
}
"@
    [System.IO.File]::WriteAllText($configFile, $configJson, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  ✅ 設定檔建立完成" -ForegroundColor Green
} else {
    Write-Host "  ✅ 設定檔已存在" -ForegroundColor Green
}

# SOUL.md
if (-not (Test-Path "$workspaceDir\SOUL.md")) {
    "# 🦞 OpenClaw Assistant`n`nI'm your AI assistant. Ask me anything!`n`nBe helpful, be concise, be friendly." | Set-Content "$workspaceDir\SOUL.md" -Encoding UTF8
}

Write-Host "  ✅ 設定完成" -ForegroundColor Green

# ======== Step 4: Token 設定引導 ========
Write-Host ""
Write-Host "🔑 [4/5] AI Token 設定" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $authFile) {
    Write-Host "  ✅ Token 已存在，跳過" -ForegroundColor Green
} else {
    Write-Host "  ┌─────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │  需要 Anthropic API Token 才能讓 AI 回話  │" -ForegroundColor Cyan  
    Write-Host "  │  跟著老師一起操作，或先按 Enter 跳過     │" -ForegroundColor Cyan
    Write-Host "  └─────────────────────────────────────────┘" -ForegroundColor Cyan
    Write-Host ""
    $token = Read-Host "  貼上你的 Token（或按 Enter 跳過）"
    
    if ($token -and $token.Length -gt 10) {
        $authJson = @"
{
  "version": 1,
  "profiles": {
    "anthropic:manual": {
      "type": "token",
      "provider": "anthropic",
      "token": "$token"
    }
  },
  "order": { "anthropic": ["anthropic:manual"] },
  "lastGood": { "anthropic": "anthropic:manual" },
  "usageStats": {}
}
"@
        [System.IO.File]::WriteAllText($authFile, $authJson, [System.Text.UTF8Encoding]::new($false))
        Write-Host "  ✅ Token 已設定！" -ForegroundColor Green
    } else {
        Write-Host "  ⏭️  已跳過，等等在 Dashboard 裡設定也可以" -ForegroundColor Gray
    }
}

# ======== Step 5: 啟動 ========
Write-Host ""
Write-Host "🚀 [5/5] 啟動 Dashboard..." -ForegroundColor Yellow

# 先殺掉可能已經在跑的
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
    $_.CommandLine -match "openclaw.*gateway"
} | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

$gateway = Start-Process -FilePath "$NodeDir\node.exe" `
    -ArgumentList "$ocEntry", "gateway", "--port", "18789" `
    -PassThru -WindowStyle Minimized

Write-Host "  ⏳ 等待啟動..." -ForegroundColor Gray
Start-Sleep -Seconds 6

# 確認是否成功
try {
    $health = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -UseBasicParsing -TimeoutSec 5
    if ($health.StatusCode -eq 200) {
        Write-Host "  ✅ Dashboard 啟動成功！" -ForegroundColor Green
    }
} catch {
    Write-Host "  ⚠️  Dashboard 可能還在啟動中，請稍等幾秒" -ForegroundColor Yellow
}

# 開瀏覽器
Start-Process "http://127.0.0.1:18789"

Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  🎉 OpenClaw 安裝完成！                    ║" -ForegroundColor Green
Write-Host "  ║                                           ║" -ForegroundColor Green
Write-Host "  ║  📍 Dashboard: http://127.0.0.1:18789     ║" -ForegroundColor Green
Write-Host "  ║                                           ║" -ForegroundColor Green
Write-Host "  ║  瀏覽器應該已經自動打開                    ║" -ForegroundColor Green
Write-Host "  ║  如果沒有，手動輸入上面的網址              ║" -ForegroundColor Green
Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  💡 Windows 防火牆如果跳出提示，請按「允許」" -ForegroundColor Yellow
Write-Host ""
Write-Host "  按任意鍵關閉此視窗（Dashboard 繼續在背景跑）..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
