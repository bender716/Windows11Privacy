<#
    Audit-WindowsTelemetry-Continuous.ps1
    Continuously monitors outbound TCP connections in real time.
    Logs any connections whose remote host/IP matches telemetry patterns.
    Duration controlled by -t parameter (10–600 seconds).

    Usage:
      .\Audit-WindowsTelemetry-Continuous.ps1 -t 120
#>

param(
    [int]$t = 60
)

if ($t -lt 10)  { $t = 10 }
if ($t -gt 600) { $t = 600 }

$base   = "C:\Users\LocalUser\Documents\AdminScripts"
$logDir = Join-Path $base "Logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir ("Telemetry_ContinuousAudit_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

Write-Host "`n=== Real-time telemetry monitoring started ($t seconds) ===`n"
Write-Host "Logging to: $logFile`n"

# Known telemetry & Microsoft network patterns
$patterns = 'telemetry|vortex|settings-win|oneclient|windowsupdate|microsoft|bing|live|edge|office|xbox|msft'

# Used to avoid duplicate log entries
$seen = @{}

$endTime = (Get-Date).AddSeconds($t)

while ((Get-Date) -lt $endTime) {
    try {
        $connections = Get-NetTCPConnection -State Established |
            Where-Object { $_.RemoteAddress -and $_.OwningProcess -ne 0 }

        foreach ($conn in $connections) {
            $key = "$($conn.OwningProcess):$($conn.RemoteAddress):$($conn.RemotePort)"
            if (-not $seen.ContainsKey($key)) {
                $seen[$key] = $true

                try {
                    $proc = (Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue)
                    $resolvedHost = (Resolve-DnsName -Name $conn.RemoteAddress -ErrorAction SilentlyContinue).NameHost
		    if (-not $resolvedHost) { $resolvedHost = "Unresolved" }
                } catch {
                    $proc = $null
                    $resolvedHost = "Unresolved"
                }

                $record = [PSCustomObject]@{
                    Timestamp  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                    Process    = if ($proc) { $proc.ProcessName } else { "Unknown" }
                    PID        = $conn.OwningProcess
                    RemoteAddr = $conn.RemoteAddress
                    RemoteHost = if ($resolvedHost) { $resolvedHost } else { "Unresolved" }
                    Port       = $conn.RemotePort
                }

                # Check for telemetry match
                if ($record.RemoteHost -match $patterns -or $record.RemoteAddr -match $patterns) {
                    Write-Host ("⚠️  {0} | {1} → {2}:{3} ({4})" -f $record.Timestamp, $record.Process, $record.RemoteHost, $record.Port, $record.RemoteAddr)
                }

                # Log all entries
                $record | ConvertTo-Json -Compress | Out-File -FilePath $logFile -Append
            }
        }
    } catch {
        Write-Host "Error reading connections: $($_.Exception.Message)"
    }

    Start-Sleep -Seconds 1
}

Write-Host "`n=== Monitoring complete ==="
Write-Host "Total unique connections observed: $($seen.Count)"
Write-Host "Full JSON log saved to: $logFile`n"
