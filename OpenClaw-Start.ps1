# Полноэкранный режим (F11 в Windows Terminal)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll", SetLastError = true)]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);
}
"@

$hwnd = [Win32]::GetForegroundWindow()
[Win32]::SetForegroundWindow($hwnd) | Out-Null
# F11 = native fullscreen в Windows Terminal
[Win32]::keybd_event(0x7A, 0, 0, [UIntPtr]::Zero)
Start-Sleep -Milliseconds 50
[Win32]::keybd_event(0x7A, 0, 2, [UIntPtr]::Zero)

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

# Убиваем старый gateway
openclaw gateway stop 2>$null | Out-Null

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
