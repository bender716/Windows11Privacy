<#
  Restore-WindowsPrivacyDefaults.ps1
  Reverts all privacy baseline changes to Windows defaults.
#>

$base = "C:\Users\LocalUser\Documents\AdminScripts"
$logDir = Join-Path $base "Logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$log = Join-Path $logDir ("PrivacyRestore_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

Write-Output "`n=== Restoring Windows Privacy Defaults ===`n" | Tee-Object -FilePath $log -Append

# --- Restore services ---
$services = @("DiagTrack","dmwappushservice","WerSvc","PcaSvc")
foreach ($svc in $services) {
    Write-Output "Restoring service: $svc" | Tee-Object -FilePath $log -Append
    Set-Service $svc -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service $svc -ErrorAction SilentlyContinue
}

# --- Re-enable tasks ---
$tasks = @(
  "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
  "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
  "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
  "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask",
  "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
  "\Microsoft\Windows\Feedback\Siuf\DmClient",
  "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
)
foreach ($t in $tasks) {
    try { Enable-ScheduledTask -TaskName $t -ErrorAction Stop } catch {}
}

# --- Reset per-user registry keys to default values ---
$regKeys = @(
    @{Path="Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager";Name="ContentDeliveryAllowed";Value=1},
    @{Path="Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo";Name="Enabled";Value=1},
    @{Path="Software\Microsoft\Windows\CurrentVersion\Privacy";Name="TailoredExperiencesWithDiagnosticDataEnabled";Value=1}
)

$profiles = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" |
    Where-Object { $_.GetValue("ProfileImagePath") -match "Users" }

foreach ($profile in $profiles) {
    $sid = $profile.PSChildName
    foreach ($r in $regKeys) {
        $path = "Registry::HKEY_USERS\$sid\$($r.Path)"
        if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
        New-ItemProperty -Path $path -Name $r.Name -PropertyType DWord -Value $r.Value -Force | Out-Null
    }
}

Write-Output "`nDefaults restored. Reboot recommended.`n" | Tee-Object -FilePath $log -Append
