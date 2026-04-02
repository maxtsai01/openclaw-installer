# 🦞 OpenClaw 一鍵安裝

全新電腦，一行指令，直接打開 Dashboard。

## Windows

以**系統管理員**身份打開 PowerShell，貼上：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; irm https://raw.githubusercontent.com/ctmaxs/openclaw-installer/main/install.ps1 | iex
```

## Mac

打開終端機，貼上：

```bash
curl -fsSL https://raw.githubusercontent.com/ctmaxs/openclaw-installer/main/install.sh | bash
```

## 安裝完成後

1. 瀏覽器會自動打開 `http://127.0.0.1:18789`
2. 在 Dashboard 裡設定你的 AI Token
3. 開始跟 AI 對話！

## 想串接通訊軟體？

在 Dashboard 裡可以自己設定：
- Discord Bot
- LINE@
- Telegram
- WhatsApp

---

Made with 🦞 by [CTMaxs](https://ctmaxs.com)
