param(
    [string]$ProjectPath,
    [ValidateRange(1, 168)][int]$Hours = 24
)

$ErrorActionPreference = 'Stop'

function Try-Read([scriptblock]$Action) {
    try { & $Action } catch { @{ error = $_.Exception.Message } }
}

$os = Try-Read {
    Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version,
        @{Name='LastBoot';Expression={$_.LastBootUpTime.ToString('o')}},
        @{Name='TotalMemoryGB';Expression={[math]::Round($_.TotalVisibleMemorySize / 1MB, 1)}},
        @{Name='FreeMemoryGB';Expression={[math]::Round($_.FreePhysicalMemory / 1MB, 1)}}
}
$cpu = Try-Read { Get-CimInstance Win32_Processor | Select-Object -First 1 Name, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage }
$gpu = Try-Read { @(Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion) }
$drives = Try-Read {
    @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object DeviceID,
        @{Name='SizeGB';Expression={[math]::Round($_.Size / 1GB, 1)}},
        @{Name='FreeGB';Expression={[math]::Round($_.FreeSpace / 1GB, 1)}})
}
$topProcesses = Try-Read {
    @(Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 8 Name, Id,
        @{Name='WorkingSetMB';Expression={[math]::Round($_.WorkingSet64 / 1MB, 0)}},
        @{Name='CpuSeconds';Expression={if ($null -eq $_.CPU) { $null } else { [math]::Round($_.CPU, 0) }}})
}

$start = (Get-Date).AddHours(-$Hours)
$systemEvents = Try-Read {
    @(Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start; Id=41,6008,18,19,4101,7,51,153} -MaxEvents 30 -ErrorAction Stop |
        Select-Object @{Name='Time';Expression={$_.TimeCreated.ToString('o')}}, ProviderName, Id, LevelDisplayName)
}
$appEvents = Try-Read {
    @(Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start; Id=1000,1001,1002} -MaxEvents 30 -ErrorAction Stop |
        Select-Object @{Name='Time';Expression={$_.TimeCreated.ToString('o')}}, ProviderName, Id, LevelDisplayName)
}

$ueLog = $null
if ($ProjectPath) {
    $logDir = Join-Path $ProjectPath 'Saved\Logs'
    if (Test-Path -LiteralPath $logDir -PathType Container) {
        $latest = Get-ChildItem -LiteralPath $logDir -File -Filter '*.log' |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($latest) {
            $matches = Try-Read {
                @(Get-Content -LiteralPath $latest.FullName -Tail 3000 -ErrorAction Stop |
                    Select-String -Pattern 'Fatal error|GPU crashed|out of video memory|EXCEPTION_ACCESS_VIOLATION|LogWindows: Error|LogRHI: Error' |
                    Select-Object -Last 20 | ForEach-Object { $_.Line.Trim() })
            }
            $ueLog = @{ path = $latest.FullName; modified = $latest.LastWriteTime.ToString('o'); matchingLines = $matches }
        }
    } else {
        $ueLog = @{ error = "No Saved\Logs directory at the supplied project path" }
    }
}

[pscustomobject]@{
    capturedAt = (Get-Date).ToString('o')
    hours = $Hours
    os = $os
    cpu = $cpu
    gpu = $gpu
    drives = $drives
    topProcessesByMemory = $topProcesses
    systemEvents = $systemEvents
    applicationEvents = $appEvents
    latestUeLog = $ueLog
} | ConvertTo-Json -Depth 6

