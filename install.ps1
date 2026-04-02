# ============================================
# 🦞 OpenClaw 一鍵安裝（Windows 版）v3
#
# 安裝方式（二擇一）：
#
# 方法 A（推薦）：下載後執行
#   1. 右鍵「以系統管理員身份執行」Windows PowerShell
#   2. 貼上：
#      Invoke-WebRequest -Uri "https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.ps1" -OutFile "$env:TEMP\install-openclaw.ps1"; & "$env:TEMP\install-openclaw.ps1"
#
# 方法 B（進階）：直接 pipe（注意：Token 步驟會自動跳過）
#   Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.ps1 | iex
# ============================================

$ErrorActionPreference = "Continue"
$NodeVersion = "22.14.0"
$InstallDir = "$env:USERPROFILE\openclaw"
$NodeDir = "$InstallDir\node"
$NodeZip = "$env:TEMP\node-openclaw.zip"
$NodeUrl = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"

Clear-Host
Write-Host ""
Write-Host "  🦞 OpenClaw 一鍵安裝 for Windows v3" -ForegroundColor Cyan
Write-Host "  =====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  全程自動，請耐心等待約 3-5 分鐘" -ForegroundColor Gray
Write-Host ""

# ======== 前置檢查 ========
# 檢查 Windows 版本
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "  ❌ 需要 Windows 10 或以上版本" -ForegroundColor Red
    pause; exit 1
}

# 檢查是否 64 位元
if (-not [Environment]::Is64BitOperatingSystem) {
    Write-Host "  ❌ 需要 64 位元 Windows" -ForegroundColor Red
    pause; exit 1
}

# 檢查網路
Write-Host "🔍 檢查網路連線..." -ForegroundColor Yellow
try {
    $null = Invoke-WebRequest -Uri "https://nodejs.org" -UseBasicParsing -TimeoutSec 10 -Method Head
    Write-Host "  ✅ 網路正常" -ForegroundColor Green
} catch {
    Write-Host "  ❌ 無法連線網路！請檢查 WiFi 或網路線" -ForegroundColor Red
    pause; exit 1
}

# ======== Step 1: Node.js ========
Write-Host "📦 [1/4] 安裝 Node.js..." -ForegroundColor Yellow
if (Test-Path "$NodeDir\node.exe") {
    Write-Host "  ✅ Node.js 已存在，跳過" -ForegroundColor Green
} else {
    try {
        Write-Host "  ⬇️  下載中（約 30MB）..." -ForegroundColor Gray
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        
        # 用 .NET WebClient（比 Invoke-WebRequest 快，有進度）
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($NodeUrl, $NodeZip)
        
        Write-Host "  📂 解壓中..." -ForegroundColor Gray
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
        Expand-Archive -Path $NodeZip -DestinationPath "$InstallDir\temp" -Force
        
        if (Test-Path $NodeDir) { Remove-Item $NodeDir -Recurse -Force }
        Move-Item "$InstallDir\temp\node-v$NodeVersion-win-x64" $NodeDir -Force
        Remove-Item "$InstallDir\temp" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $NodeZip -Force -ErrorAction SilentlyContinue
        
        Write-Host "  ✅ Node.js v$NodeVersion 安裝完成" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Node.js 下載失敗！" -ForegroundColor Red
        Write-Host "  錯誤：$($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  請截圖給老師" -ForegroundColor Yellow
        pause; exit 1
    }
}
$env:PATH = "$NodeDir;$env:PATH"

# ======== Step 2: OpenClaw ========
Write-Host "📦 [2/4] 安裝 OpenClaw（約 2-3 分鐘）..." -ForegroundColor Yellow
$ocEntry = "$NodeDir\node_modules\openclaw\dist\index.js"

if (Test-Path $ocEntry) {
    Write-Host "  ✅ OpenClaw 已安裝，跳過" -ForegroundColor Green
} else {
    $npmOutput = & "$NodeDir\npm.cmd" install -g openclaw --ignore-scripts 2>&1
    
    if (Test-Path $ocEntry) {
        Write-Host "  ✅ OpenClaw 安裝完成" -ForegroundColor Green
    } else {
        Write-Host "  ❌ 安裝失敗！" -ForegroundColor Red
        Write-Host "  $($npmOutput | Out-String)" -ForegroundColor Gray
        Write-Host "  請截圖給老師" -ForegroundColor Yellow
        pause; exit 1
    }
}

# ======== Step 3: 設定檔 ========
Write-Host "🔧 [3/4] 建立設定..." -ForegroundColor Yellow

# 用 %USERPROFILE%\.openclaw 避免中文路徑問題
$configDir = "$env:USERPROFILE\.openclaw"
$configFile = "$configDir\openclaw.json"
$agentDir = "$configDir\agents\main\agent"
$workspaceDir = "$configDir\workspace"
$authFile = "$agentDir\auth-profiles.json"

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null
New-Item -ItemType Directory -Path "$workspaceDir\memory" -Force | Out-Null

# 設定檔（用正斜線避免 JSON escape 問題）
if (-not (Test-Path $configFile)) {
    $wsForward = $workspaceDir -replace '\\', '/'
    $adForward = $agentDir -replace '\\', '/'
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
        "workspace": "$wsForward",
        "agentDir": "$adForward",
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

# auth-profiles（空的，等學員設定）
if (-not (Test-Path $authFile)) {
    $emptyAuth = '{"version":1,"profiles":{},"order":{},"usageStats":{}}'
    [System.IO.File]::WriteAllText($authFile, $emptyAuth, [System.Text.UTF8Encoding]::new($false))
}

# SOUL.md
if (-not (Test-Path "$workspaceDir\SOUL.md")) {
    $soul = "# OpenClaw Assistant`r`n`r`nI'm your AI assistant powered by Claude. Ask me anything!`r`n`r`nBe helpful, be concise, be friendly."
    [System.IO.File]::WriteAllText("$workspaceDir\SOUL.md", $soul, [System.Text.UTF8Encoding]::new($false))
}

Write-Host "  ✅ 設定完成" -ForegroundColor Green

# ======== Step 4: 啟動 ========
Write-Host "🚀 [4/4] 啟動 Dashboard..." -ForegroundColor Yellow

# 檢查 port 是否被佔
$portInUse = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue
if ($portInUse) {
    Write-Host "  ⚠️  Port 18789 已被使用，嘗試關閉舊的..." -ForegroundColor Yellow
    $portInUse | ForEach-Object {
        Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2
}

# 啟動 Gateway
$gateway = Start-Process -FilePath "$NodeDir\node.exe" `
    -ArgumentList "$ocEntry", "gateway", "--port", "18789" `
    -PassThru -WindowStyle Minimized

Write-Host "  ⏳ 等待啟動..." -ForegroundColor Gray
Start-Sleep -Seconds 8

# 確認是否成功（重試 3 次）
$success = $false
for ($i = 1; $i -le 3; $i++) {
    try {
        $health = Invoke-WebRequest -Uri "http://127.0.0.1:18789/health" -UseBasicParsing -TimeoutSec 5
        if ($health.StatusCode -eq 200) {
            $success = $true
            break
        }
    } catch {
        Start-Sleep -Seconds 3
    }
}

if ($success) {
    Write-Host "  ✅ Dashboard 啟動成功！" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Dashboard 還在啟動中，請稍等 10 秒再開瀏覽器" -ForegroundColor Yellow
}

# 開瀏覽器
Start-Process "http://127.0.0.1:18789"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  🎉 OpenClaw 安裝完成！                       ║" -ForegroundColor Green
Write-Host "  ║                                              ║" -ForegroundColor Green
Write-Host "  ║  📍 Dashboard: http://127.0.0.1:18789        ║" -ForegroundColor Green
Write-Host "  ║                                              ║" -ForegroundColor Green
Write-Host "  ║  📌 下一步：在 Dashboard 裡面                 ║" -ForegroundColor Green
Write-Host "  ║     點右上角設定 → 貼上 AI Token              ║" -ForegroundColor Green
Write-Host "  ║     （跟著老師一起做）                        ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "  💡 如果 Windows 防火牆跳出提示，請按「允許存取」" -ForegroundColor Yellow
Write-Host ""
Write-Host "  📁 安裝位置：" -ForegroundColor Gray
Write-Host "     Node.js: $NodeDir" -ForegroundColor Gray
Write-Host "     OpenClaw: $configDir" -ForegroundColor Gray
Write-Host ""
Write-Host "  按任意鍵關閉此視窗（Dashboard 繼續在背景跑）..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
