<#
  Apply-WindowsPrivacyBaseline.ps1
  System-wide and per-user Windows 11 privacy baseline.
  Re-run after feature updates.  Requires Administrator.
#>

$base = "C:\Users\LocalUser\Documents\AdminScripts"
$logDir = Join-Path $base "Logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("PrivacyBaseline_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

Write-Output "`n=== Applying Windows Privacy Baseline ===`n" | Tee-Object -FilePath $log -Append

# --- Disable telemetry-related services ---
$services = @("DiagTrack","dmwappushservice","WerSvc","PcaSvc")
foreach ($svc in $services) {
    Write-Output "Disabling service: $svc" | Tee-Object -FilePath $log -Append
    Stop-Service $svc -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# --- Disable telemetry scheduled tasks ---
$tasks = @(
  "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
  "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
  "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
  "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
  "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
  "\Microsoft\Windows\Autochk\Proxy",
  "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
  "\Microsoft\Windows\Feedback\Siuf\DmClient",
  "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
)
foreach ($t in $tasks) {
    try { Disable-ScheduledTask -TaskName $t -ErrorAction Stop } catch {}
}

# --- Apply per-user registry privacy keys to currently loaded profiles only ---
Write-Host "`nApplying user-level privacy settings...`n"

$hku = Get-ChildItem Registry::HKEY_USERS | Where-Object {
    $_.Name -match '^HKEY_USERS\\S-1-5-21' -and
    $_.Name -notmatch '(_Classes|_Default)'
}

foreach ($u in $hku) {
    $sid = $u.PSChildName
    Write-Host " - User SID: $sid"

    $userKeys = @(
        "Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
        "Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo",
        "Software\Microsoft\Windows\CurrentVersion\Privacy"
    )

    foreach ($sub in $userKeys) {
        $path = "Registry::HKEY_USERS\$sid\$sub"
        try {
            if (!(Test-Path $path)) {
                New-Item -Path $path -Force | Out-Null
            }

            switch -Regex ($sub) {
                "ContentDeliveryManager" {
                    New-ItemProperty -Path $path -Name "ContentDeliveryAllowed" -Value 0 -PropertyType DWord -Force | Out-Null
                    New-ItemProperty -Path $path -Name "SubscribedContent-338388Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
                    New-ItemProperty -Path $path -Name "SubscribedContent-353694Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
                }
                "AdvertisingInfo" {
                    New-ItemProperty -Path $path -Name "Enabled" -Value 0 -PropertyType DWord -Force | Out-Null
                }
                "Privacy" {
                    New-ItemProperty -Path $path -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -PropertyType DWord -Force | Out-Null
                }
            }
        }
        catch {
            Write-Warning "Skipped unloaded user hive: $sid ($sub)"
        }
    }
}

Write-Output "`nBaseline applied. Reboot recommended.`n" | Tee-Object -FilePath $log -Append
