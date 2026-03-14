# Развернуть окно на весь экран (с таскбаром)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$hwnd = [Win32]::GetForegroundWindow()
[Win32]::ShowWindow($hwnd, 3) | Out-Null  # 3 = SW_MAXIMIZE

$Host.UI.RawUI.WindowTitle = "OpenClaw + Nemotron 3 Super"
$env:OLLAMA_MODELS = "E:\ollama\models"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw + NVIDIA Nemotron 3 Super"    -ForegroundColor Cyan
Write-Host "  Cloud Edition"                          -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Ollama
if (-not (Get-Process -Name "ollama" -ErrorAction SilentlyContinue)) {
    Write-Host "[*] Starting Ollama..." -ForegroundColor Yellow
    Start-Process "C:\Users\mizuki\AppData\Local\Programs\Ollama\ollama app.exe"
    do { Start-Sleep -Seconds 1 } until (
        (Test-NetConnection -ComputerName 127.0.0.1 -Port 11434 -WarningAction SilentlyContinue).TcpTestSucceeded
    )
}
Write-Host "[OK] Ollama" -ForegroundColor Green

# Убиваем старый gateway (тихо, без мигающих окон)
$gwProc = Get-NetTCPConnection -LocalPort 18789 -ErrorAction SilentlyContinue |
          Select-Object -ExpandProperty OwningProcess -Unique
if ($gwProc) { $gwProc | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue } }

# Чистим историю чатов — память живёт в файлах (USER.md, MEMORY.md, memory/)
# AGENTS.md сам говорит: "You wake up fresh each session"
$sessDir = "$env:USERPROFILE\.openclaw\agents\main\sessions"
if (Test-Path $sessDir) {
    Remove-Item "$sessDir\*.jsonl" -Force -ErrorAction SilentlyContinue
    Remove-Item "$sessDir\sessions.json" -Force -ErrorAction SilentlyContinue
}

Write-Host "[*] Launching OpenClaw..." -ForegroundColor Yellow
Write-Host "    Web UI: " -NoNewline; Write-Host "http://localhost:18789/#token=ollama" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

ollama launch openclaw --model nemotron-3-super:cloud --yes
