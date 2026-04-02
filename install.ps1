# ============================================
# 🦞 OpenClaw 一鍵安裝（Windows 版）
# 用法：在 PowerShell 貼上：
#   irm https://raw.githubusercontent.com/ctmaxs/openclaw-installer/main/install.ps1 | iex
# ============================================

$ErrorActionPreference = "Stop"
$NodeVersion = "22.14.0"
$NodeDir = "C:\openclaw\node"
$NodeZip = "$env:TEMP\node.zip"
$NodeUrl = "https://nodejs.org/dist/v$NodeVersion/node-v$NodeVersion-win-x64.zip"

Write-Host ""
Write-Host "🦞 OpenClaw 一鍵安裝 for Windows" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# ---- Step 1: Node.js ----
if (Test-Path "$NodeDir\node.exe") {
    Write-Host "✅ Node.js 已存在" -ForegroundColor Green
} else {
    Write-Host "📦 [1/4] 下載 Node.js v$NodeVersion..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZip -UseBasicParsing
    
    Write-Host "📂 解壓中..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "C:\openclaw" -Force | Out-Null
    Expand-Archive -Path $NodeZip -DestinationPath "C:\openclaw\temp" -Force
    Move-Item "C:\openclaw\temp\node-v$NodeVersion-win-x64" $NodeDir -Force
    Remove-Item "C:\openclaw\temp" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $NodeZip -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Node.js 安裝完成" -ForegroundColor Green
}

$env:PATH = "$NodeDir;$env:PATH"

# ---- Step 2: OpenClaw ----
Write-Host "📦 [2/4] 安裝 OpenClaw（約 2-3 分鐘）..." -ForegroundColor Yellow
& "$NodeDir\npm.cmd" install -g openclaw --ignore-scripts 2>&1 | Out-Null
if (Test-Path "$NodeDir\node_modules\openclaw\dist\index.js") {
    Write-Host "✅ OpenClaw 安裝完成" -ForegroundColor Green
} else {
    Write-Host "❌ 安裝失敗，請找老師幫忙" -ForegroundColor Red
    pause
    exit 1
}

# ---- Step 3: 基本設定 ----
Write-Host "🔧 [3/4] 建立設定..." -ForegroundColor Yellow
$configDir = "$env:USERPROFILE\.openclaw"
$configFile = "$configDir\openclaw.json"
$agentDir = "$configDir\agents\main\agent"
$workspaceDir = "$configDir\workspace"

New-Item -ItemType Directory -Path $configDir -Force | Out-Null
New-Item -ItemType Directory -Path $agentDir -Force | Out-Null
New-Item -ItemType Directory -Path $workspaceDir -Force | Out-Null

# 最簡設定 — 只開 Dashboard，不串任何通道
if (-not (Test-Path $configFile)) {
    @"
{
  "gateway": {
    "mode": "local",
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "local-$(Get-Random -Maximum 999999)"
    }
  },
  "agents": {
    "list": [
      {
        "id": "main",
        "name": "main",
        "workspace": "$($workspaceDir -replace '\\', '\\\\')",
        "agentDir": "$($agentDir -replace '\\', '\\\\')",
        "model": "anthropic/claude-sonnet-4-6"
      }
    ]
  }
}
"@ | Set-Content $configFile -Encoding UTF8
    Write-Host "✅ 設定檔建立完成" -ForegroundColor Green
} else {
    Write-Host "✅ 設定檔已存在" -ForegroundColor Green
}

# 建立基礎 workspace 檔案
if (-not (Test-Path "$workspaceDir\SOUL.md")) {
    "# Hi! I'm your OpenClaw assistant. Ask me anything!" | Set-Content "$workspaceDir\SOUL.md" -Encoding UTF8
}

Write-Host "✅ 設定完成" -ForegroundColor Green

# ---- Step 4: 啟動 ----
Write-Host "🚀 [4/4] 啟動 Dashboard..." -ForegroundColor Yellow
$gateway = Start-Process -FilePath "$NodeDir\node.exe" -ArgumentList "$NodeDir\node_modules\openclaw\dist\index.js", "gateway", "--port", "18789" -PassThru -WindowStyle Minimized
Start-Sleep -Seconds 5

# 開瀏覽器
Start-Process "http://127.0.0.1:18789"

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "🎉 安裝完成！Dashboard 已在瀏覽器開啟" -ForegroundColor Green
Write-Host "" -ForegroundColor Green
Write-Host "📍 Dashboard: http://127.0.0.1:18789" -ForegroundColor Cyan
Write-Host "" -ForegroundColor Green
Write-Host "📌 下一步：在 Dashboard 裡設定 AI Token" -ForegroundColor Yellow
Write-Host "   （跟著老師一起做）" -ForegroundColor Yellow
Write-Host "============================================" -ForegroundColor Green
Write-Host ""
Write-Host "按任意鍵結束（Dashboard 會繼續在背景運行）..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
