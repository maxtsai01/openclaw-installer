#!/bin/bash
# ============================================
# 🦞 OpenClaw 一鍵安裝（Mac 版）
# 用法：curl -fsSL https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.sh | bash
# ============================================

set -e

echo ""
echo "  🦞 OpenClaw 一鍵安裝 for Mac"
echo "  ================================="
echo ""
echo "  全程自動，請耐心等待約 3-5 分鐘"
echo ""

# ======== Step 1: Homebrew + Node.js ========
echo "📦 [1/5] 檢查 Node.js..."

if command -v node &>/dev/null; then
    echo "  ✅ Node.js $(node -v) 已安裝"
else
    echo "  ⬇️  需要安裝 Node.js..."
    
    # 先檢查 Homebrew
    if ! command -v brew &>/dev/null; then
        echo "  ⬇️  安裝 Homebrew（需要輸入電腦密碼）..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # M1/M2/M3 Mac 需要加 PATH
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
    fi
    
    echo "  ⬇️  安裝 Node.js..."
    brew install node
    echo "  ✅ Node.js $(node -v) 安裝完成"
fi

# ======== Step 2: OpenClaw ========
echo "📦 [2/5] 安裝 OpenClaw..."

if command -v openclaw &>/dev/null; then
    echo "  ✅ OpenClaw 已安裝"
else
    # Mac 可能需要 sudo
    if npm install -g openclaw 2>/dev/null; then
        echo "  ✅ OpenClaw 安裝完成"
    else
        echo "  🔐 需要管理員權限，請輸入電腦密碼..."
        sudo npm install -g openclaw
        echo "  ✅ OpenClaw 安裝完成"
    fi
fi

# ======== Step 3: 設定檔 ========
echo "🔧 [3/5] 建立設定..."

CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
AGENT_DIR="$CONFIG_DIR/agents/main/agent"
WORKSPACE_DIR="$CONFIG_DIR/workspace"
AUTH_FILE="$AGENT_DIR/auth-profiles.json"

mkdir -p "$CONFIG_DIR" "$AGENT_DIR" "$WORKSPACE_DIR" "$WORKSPACE_DIR/memory"

if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << 'CONFIGEOF'
{
  "gateway": {
    "mode": "local",
    "auth": {
      "mode": "open"
    }
  },
  "agents": {
    "list": [
      {
        "id": "main",
        "name": "main",
        "model": "anthropic/claude-sonnet-4-6"
      }
    ]
  }
}
CONFIGEOF
    echo "  ✅ 設定檔建立完成"
else
    echo "  ✅ 設定檔已存在"
fi

# SOUL.md
if [ ! -f "$WORKSPACE_DIR/SOUL.md" ]; then
    echo "# 🦞 OpenClaw Assistant

I'm your AI assistant. Ask me anything!

Be helpful, be concise, be friendly." > "$WORKSPACE_DIR/SOUL.md"
fi

echo "  ✅ 設定完成"

# ======== Step 4: Token ========
echo ""
echo "🔑 [4/5] AI Token 設定"
echo ""

if [ -f "$AUTH_FILE" ]; then
    echo "  ✅ Token 已存在，跳過"
else
    echo "  ┌─────────────────────────────────────────┐"
    echo "  │  需要 Anthropic API Token 才能讓 AI 回話  │"
    echo "  │  跟著老師一起操作，或直接按 Enter 跳過     │"
    echo "  └─────────────────────────────────────────┘"
    echo ""
    read -p "  貼上你的 Token（或按 Enter 跳過）: " TOKEN
    
    if [ -n "$TOKEN" ] && [ ${#TOKEN} -gt 10 ]; then
        cat > "$AUTH_FILE" << AUTHEOF
{
  "version": 1,
  "profiles": {
    "anthropic:manual": {
      "type": "token",
      "provider": "anthropic",
      "token": "$TOKEN"
    }
  },
  "order": { "anthropic": ["anthropic:manual"] },
  "lastGood": { "anthropic": "anthropic:manual" },
  "usageStats": {}
}
AUTHEOF
        echo "  ✅ Token 已設定！"
    else
        echo "  ⏭️  已跳過，等等在 Dashboard 裡設定也可以"
    fi
fi

# ======== Step 5: 啟動 ========
echo ""
echo "🚀 [5/5] 啟動 Dashboard..."

# 用 LaunchAgent 或直接跑
openclaw gateway start 2>/dev/null || (
    echo "  ⚠️  LaunchAgent 啟動失敗，改用直接啟動..."
    nohup openclaw gateway --port 18789 > /dev/null 2>&1 &
)

sleep 4

# 確認是否成功
if curl -s http://127.0.0.1:18789/health 2>/dev/null | grep -q "ok"; then
    echo "  ✅ Dashboard 啟動成功！"
else
    echo "  ⚠️  Dashboard 可能還在啟動中，請稍等幾秒"
fi

# 開瀏覽器
open "http://127.0.0.1:18789" 2>/dev/null || true

echo ""
echo "  ╔═══════════════════════════════════════════╗"
echo "  ║  🎉 OpenClaw 安裝完成！                    ║"
echo "  ║                                           ║"
echo "  ║  📍 Dashboard: http://127.0.0.1:18789     ║"
echo "  ║                                           ║"
echo "  ║  瀏覽器應該已經自動打開                    ║"
echo "  ║  如果沒有，手動輸入上面的網址              ║"
echo "  ╚═══════════════════════════════════════════╝"
echo ""
