# ReStory - Firmware Fix (Guitar Legend / devices with no UNLOCK-TOOLKIT content)
# Usage: drag the game folder onto APPLY_PATCH.bat, or put this folder inside the game folder.
param([string]$GamePath = "", [switch]$Restore)

$ErrorActionPreference = "Stop"

function Find-Dll([string]$path) {
    if ($path -and (Test-Path -LiteralPath $path -PathType Leaf)) { return (Resolve-Path -LiteralPath $path).Path }
    $bases = @()
    if ($path) { $bases += $path }
    $bases += $PSScriptRoot, (Split-Path $PSScriptRoot -Parent)
    foreach ($b in $bases) {
        foreach ($rel in "Restory_Data\Managed\Restory.Assembly.dll", "Managed\Restory.Assembly.dll", "Restory.Assembly.dll") {
            $p = Join-Path $b $rel
            if (Test-Path -LiteralPath $p -PathType Leaf) { return (Resolve-Path -LiteralPath $p).Path }
        }
    }
    throw "Restory.Assembly.dll not found. Provide the game folder (where Restory.exe is)."
}

try {
    $dll = Find-Dll $GamePath
    $backup = "$dll.bak"

    if ($Restore) {
        if (-not (Test-Path -LiteralPath $backup)) { throw "Backup not found: $backup" }
        Copy-Item -LiteralPath $backup -Destination $dll -Force
        Write-Host "Original restored: $dll" -ForegroundColor Green
        exit 0
    }

    # Latin1 maps each byte 1:1 to a char, allowing regex over raw bytes
    $latin1 = [System.Text.Encoding]::GetEncoding(28591)
    $bytes = [System.IO.File]::ReadAllBytes($dll)
    $text = $latin1.GetString($bytes)

    $T = '[\s\S]{4}'
    $branch = '\x04\x02\x7B' + $T + '\x51\x05\x02\x7B' + $T + '\x51\x17\x2A'
    $compare = '\x03\x6F' + $T + '\x02\x7B' + $T + '\x6F' + $T + '\x28' + $T + '\x2C[\s\S]'
    $head = '\x04\x02\x7B([\s\S]{4})\x51\x05\x02\x7B([\s\S]{4})\x51\x17\x2A' + $compare + $branch + $compare + $branch
    $pattern = $head + '(\x72' + $T + '\x03\x6F' + $T + '\x28' + $T + '\x28' + $T + '\x16\x2A)'
    $patched = $head + '\x04\x02\x7B\1\x51\x05\x02\x7B\2\x51\x17\x2A\x00{5}'

    if ([regex]::IsMatch($text, $patched)) {
        Write-Host "Patch is already applied. Nothing to do." -ForegroundColor Yellow
        exit 0
    }
    $found = [regex]::Matches($text, $pattern)
    if ($found.Count -ne 1) { throw "Expected code not found ($($found.Count) matches). Incompatible game version." }

    $m = $found[0]
    $tok1 = $latin1.GetBytes($m.Groups[1].Value)
    $tok2 = $latin1.GetBytes($m.Groups[2].Value)
    $newTail = [byte[]](@(0x04, 0x02, 0x7B) + $tok1 + @(0x51, 0x05, 0x02, 0x7B) + $tok2 + @(0x51, 0x17, 0x2A, 0, 0, 0, 0, 0))
    $start = $m.Groups[3].Index
    if ($m.Groups[3].Length -ne 23 -or $newTail.Length -ne 23) { throw "Unexpected code block size." }

    if (-not (Test-Path -LiteralPath $backup)) {
        Copy-Item -LiteralPath $dll -Destination $backup
        Write-Host "Backup created: $backup"
    }
    [Array]::Copy($newTail, 0, $bytes, $start, 23)
    [System.IO.File]::WriteAllBytes($dll, $bytes)
    Write-Host "Patch applied successfully to: $dll" -ForegroundColor Green
}
catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
