#!/bin/bash
# ============================================
# 🦞 OpenClaw 一鍵安裝（Mac 版）
# 用法：curl -fsSL https://你的網址/install-mac.sh | bash
# ============================================

set -e
echo ""
echo "🦞 OpenClaw 一鍵安裝開始..."
echo ""

# 1. 檢查 Node.js
if ! command -v node &>/dev/null; then
    echo "❌ 請先安裝 Node.js："
    echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "   brew install node"
    exit 1
fi
echo "✅ Node.js $(node -v)"

# 2. 安裝 OpenClaw
echo "📦 安裝 OpenClaw..."
npm install -g openclaw 2>&1 | tail -3
echo "✅ OpenClaw 已安裝"

# 3. 初始化
echo "🔧 初始化設定..."
openclaw setup --skip-channels 2>/dev/null || openclaw setup 2>/dev/null || true

# 4. 啟動 Gateway
echo ""
echo "🚀 啟動 Dashboard..."
openclaw gateway start 2>/dev/null || true

echo ""
echo "============================================"
echo "🎉 安裝完成！"
echo ""
echo "👉 打開瀏覽器，輸入："
echo "   http://127.0.0.1:18789"
echo ""
echo "📌 接下來跟著老師一起設定 Token"
echo "============================================"
