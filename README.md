# OpenClaw + NVIDIA Nemotron 3 Super — Free AI Agent Setup

Run **OpenClaw** with **NVIDIA Nemotron 3 Super** for free. The model runs in NVIDIA's cloud — no GPU required on your machine.

## What You Get

- **OpenClaw** — autonomous AI agent that lives on your computer, learns from you, and can run tools
- **Nemotron 3 Super** — NVIDIA's 120B parameter model (12B active) optimized for agentic tasks
- **Cloud inference** — model runs on NVIDIA servers, your PC is just the interface
- **Web UI + Terminal** — use from browser or command line
- **Web search** — built-in plugin for real-time information
- **Free** — no API keys, no subscription, $0

## Requirements

- Windows 10/11
- Internet connection
- [PowerShell 7+](https://github.com/PowerShell/PowerShell/releases)
- ~500 MB disk space (for Ollama + OpenClaw, model is in the cloud)

## Installation

### Step 1: Install Ollama

Open PowerShell and run:

```powershell
irm https://ollama.com/install.ps1 | iex
```

Launch Ollama from the Start menu or taskbar. Wait for the tray icon to appear.

### Step 2: Pull the Cloud Model

```powershell
ollama pull nemotron-3-super:cloud
```

This downloads only a tiny manifest (~345 bytes). The model itself runs on NVIDIA's servers.

### Step 3: Launch OpenClaw

```powershell
ollama launch openclaw --model nemotron-3-super:cloud --yes
```

This will:
1. Install OpenClaw if not already installed
2. Configure it with Nemotron 3 Super
3. Start the gateway and TUI
4. Open a chat session

**Web UI** will be available at: `http://localhost:18789/#token=ollama`

### Step 4: Set Thinking Level (Optional)

In the OpenClaw chat, type:

```
/think high
```

This enables maximum reasoning depth for complex tasks.

## One-Click Launch Script

Save as `OpenClaw Start.ps1` and run with PowerShell 7:

```powershell
# Fullscreen
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
}
"@
[Win32]::ShowWindow([Win32]::GetConsoleWindow(), 3) | Out-Null

$Host.UI.RawUI.WindowTitle = "OpenClaw + Nemotron 3 Super"
$env:OLLAMA_MODELS = "E:\ollama\models"  # Change to your preferred drive

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw + NVIDIA Nemotron 3 Super"    -ForegroundColor Cyan
Write-Host "  Cloud Edition"                          -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Start Ollama if not running
if (-not (Get-Process -Name "ollama" -ErrorAction SilentlyContinue)) {
    Write-Host "[*] Starting Ollama..." -ForegroundColor Yellow
    Start-Process "C:\Users\$env:USERNAME\AppData\Local\Programs\Ollama\ollama app.exe"
    do { Start-Sleep -Seconds 1 } until (
        (Test-NetConnection -ComputerName 127.0.0.1 -Port 11434 -WarningAction SilentlyContinue).TcpTestSucceeded
    )
}
Write-Host "[OK] Ollama" -ForegroundColor Green

# Stop old gateway
openclaw gateway stop 2>$null | Out-Null

# Fresh session (memory lives in files, not chat history)
$sessDir = "$env:USERPROFILE\.openclaw\agents\main\sessions"
if (Test-Path $sessDir) {
    Remove-Item "$sessDir\*.jsonl" -Force -ErrorAction SilentlyContinue
    Remove-Item "$sessDir\sessions.json" -Force -ErrorAction SilentlyContinue
}

Write-Host "[*] Launching OpenClaw..." -ForegroundColor Yellow
Write-Host "    Web UI: " -NoNewline
Write-Host "http://localhost:18789/#token=ollama" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

ollama launch openclaw --model nemotron-3-super:cloud --yes
```

> **Note:** Change `OLLAMA_MODELS` path if you want models stored on a different drive. The cloud model is tiny, but if you ever pull local models they can be 10-90 GB.

## Customizing Your Agent

After first launch, OpenClaw creates config files in its workspace:

| File | Purpose |
|------|---------|
| `USER.md` | Info about you (name, timezone, preferences) |
| `IDENTITY.md` | Agent's name, personality, vibe |
| `AGENTS.md` | Behavior rules, memory system, tool usage |
| `SOUL.md` | Core values and principles |
| `MEMORY.md` | Long-term curated memory |
| `memory/YYYY-MM-DD.md` | Daily session logs |

Edit `USER.md` and `IDENTITY.md` to personalize the agent.

## Configuration

OpenClaw config: `~\.openclaw\openclaw.json`

Key settings:
- **Model**: `agents.defaults.model.primary` — which model to use
- **Workspace**: `agents.defaults.workspace` — agent's working directory
- **Port**: `gateway.port` — web UI port (default: 18789)

## Troubleshooting

### "Wake up" message appears multiple times
The launch script clears session history before each start. If you removed that, greeting messages accumulate across restarts.

### Agent reads too many files on startup
Set `agents.defaults.workspace` to a dedicated folder, not your entire home directory. The agent reads everything in its workspace on startup.

### Plugin warnings about "provenance"
Add the plugin to `plugins.allow` in config:
```json
"plugins": {
    "allow": ["openclaw-web-search"]
}
```

### Model hangs / slow responses
Normal for cloud models with `think high`. NVIDIA's free tier may throttle. Try `/think low` for faster responses.

### Ollama installer error "Access denied"
Ollama is already running. Close it from the system tray first, then install.

## Architecture

```
You (browser/terminal)
    ↓
OpenClaw (localhost, your PC)
    ↓
Ollama (proxy on your PC)
    ↓
NVIDIA Cloud (Nemotron 3 Super runs here)
```

- Your PC = interface only, no heavy computation
- Internet required — no internet = no AI
- PC off = agent off (it's local software connecting to cloud)

## Links

- [Ollama](https://ollama.com) — model manager
- [OpenClaw](https://docs.openclaw.ai) — AI agent platform
- [Nemotron 3 Super on Ollama](https://ollama.com/library/nemotron-3-super) — model page
- [NVIDIA OpenClaw Guide](https://www.nvidia.com/en-us/geforce/news/open-claw-rtx-gpu-dgx-spark-guide/) — official setup guide

## Credits

Setup guide by [@StrangeTeaCreature](https://github.com/StrangeTeaCreature) with help from Claude Code.
