#!/bin/bash
# ============================================
# 🦞 OpenClaw 一鍵安裝（Mac 版）v3
# 用法：curl -fsSL https://raw.githubusercontent.com/maxtsai01/openclaw-installer/main/install.sh | bash
# ============================================

echo ""
echo "  🦞 OpenClaw 一鍵安裝 for Mac v3"
echo "  ================================="
echo ""
echo "  全程自動，請耐心等待約 3-5 分鐘"
echo ""

# ======== 前置檢查 ========
# 檢查 macOS 版本
sw_vers_major=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)
if [ -n "$sw_vers_major" ] && [ "$sw_vers_major" -lt 12 ]; then
    echo "  ❌ 需要 macOS 12 或以上版本"
    exit 1
fi

# 檢查網路
echo "🔍 檢查網路連線..."
if curl -s --connect-timeout 5 https://nodejs.org > /dev/null 2>&1; then
    echo "  ✅ 網路正常"
else
    echo "  ❌ 無法連線網路！請檢查 WiFi"
    exit 1
fi

# ======== Step 1: Homebrew + Node.js ========
echo "📦 [1/4] 安裝 Node.js..."

# 確保 brew PATH 存在（M1/M2/M3）
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if command -v node &>/dev/null; then
    echo "  ✅ Node.js $(node -v) 已安裝"
else
    # 先檢查 Homebrew
    if ! command -v brew &>/dev/null; then
        echo "  ⬇️  安裝 Homebrew（可能需要輸入電腦密碼）..."
        echo "  💡 密碼輸入時不會顯示，輸完按 Enter 就好"
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            echo "  ❌ Homebrew 安裝失敗"
            echo "  請截圖給老師"
            exit 1
        }
        
        # M1/M2/M3 Mac
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile 2>/dev/null
        fi
    fi
    
    # 指定安裝 Node 22（不要最新版）
    echo "  ⬇️  安裝 Node.js v22..."
    brew install node@22 2>/dev/null || brew install node
    
    # 確保 node@22 在 PATH
    if [[ -d /opt/homebrew/opt/node@22/bin ]]; then
        export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
        echo 'export PATH="/opt/homebrew/opt/node@22/bin:$PATH"' >> ~/.zprofile 2>/dev/null
    fi
    
    if command -v node &>/dev/null; then
        echo "  ✅ Node.js $(node -v) 安裝完成"
    else
        echo "  ❌ Node.js 安裝失敗，請截圖給老師"
        exit 1
    fi
fi

# ======== Step 2: OpenClaw ========
echo "📦 [2/4] 安裝 OpenClaw..."

if command -v openclaw &>/dev/null; then
    echo "  ✅ OpenClaw 已安裝"
else
    if npm install -g openclaw 2>/dev/null; then
        echo "  ✅ OpenClaw 安裝完成"
    else
        echo "  🔐 需要管理員權限，請輸入電腦密碼..."
        echo "  💡 密碼輸入時不會顯示，輸完按 Enter 就好"
        sudo npm install -g openclaw || {
            echo "  ❌ OpenClaw 安裝失敗，請截圖給老師"
            exit 1
        }
        echo "  ✅ OpenClaw 安裝完成"
    fi
fi

# ======== Step 3: 設定檔 ========
echo "🔧 [3/4] 建立設定..."

CONFIG_DIR="$HOME/.openclaw"
CONFIG_FILE="$CONFIG_DIR/openclaw.json"
AGENT_DIR="$CONFIG_DIR/agents/main/agent"
WORKSPACE_DIR="$CONFIG_DIR/workspace"
AUTH_FILE="$AGENT_DIR/auth-profiles.json"

mkdir -p "$CONFIG_DIR" "$AGENT_DIR" "$WORKSPACE_DIR" "$WORKSPACE_DIR/memory"

if [ ! -f "$CONFIG_FILE" ]; then
    cat > "$CONFIG_FILE" << CONFIGEOF
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
        "workspace": "$WORKSPACE_DIR",
        "agentDir": "$AGENT_DIR",
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

# auth-profiles（空的，等學員設定）
if [ ! -f "$AUTH_FILE" ]; then
    echo '{"version":1,"profiles":{},"order":{},"usageStats":{}}' > "$AUTH_FILE"
fi

# SOUL.md
if [ ! -f "$WORKSPACE_DIR/SOUL.md" ]; then
    cat > "$WORKSPACE_DIR/SOUL.md" << 'SOULEOF'
# OpenClaw Assistant

I'm your AI assistant powered by Claude. Ask me anything!

Be helpful, be concise, be friendly.
SOULEOF
fi

echo "  ✅ 設定完成"

# ======== Step 4: 啟動 ========
echo ""
echo "🚀 [4/4] 啟動 Dashboard..."

# 檢查 port 是否被佔
if lsof -i :18789 -sTCP:LISTEN > /dev/null 2>&1; then
    echo "  ⚠️  Port 18789 已被使用，嘗試關閉舊的..."
    lsof -ti :18789 | xargs kill -9 2>/dev/null
    sleep 2
fi

# 啟動
openclaw gateway start 2>/dev/null || (
    nohup openclaw gateway --port 18789 > /dev/null 2>&1 &
)

echo "  ⏳ 等待啟動..."
sleep 6

# 確認是否成功（重試 3 次）
SUCCESS=false
for i in 1 2 3; do
    if curl -s http://127.0.0.1:18789/health 2>/dev/null | grep -q "ok"; then
        SUCCESS=true
        break
    fi
    sleep 3
done

if [ "$SUCCESS" = true ]; then
    echo "  ✅ Dashboard 啟動成功！"
else
    echo "  ⚠️  Dashboard 還在啟動中，請稍等 10 秒再開瀏覽器"
fi

# 開瀏覽器
open "http://127.0.0.1:18789" 2>/dev/null || true

echo ""
echo "  ╔══════════════════════════════════════════════╗"
echo "  ║  🎉 OpenClaw 安裝完成！                       ║"
echo "  ║                                              ║"
echo "  ║  📍 Dashboard: http://127.0.0.1:18789        ║"
echo "  ║                                              ║"
echo "  ║  📌 下一步：在 Dashboard 裡面                 ║"
echo "  ║     點右上角設定 → 貼上 AI Token              ║"
echo "  ║     （跟著老師一起做）                        ║"
echo "  ╚══════════════════════════════════════════════╝"
echo ""
