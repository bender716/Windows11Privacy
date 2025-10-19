<#
  Restore-UserPrivacy.ps1
  Run inside any logged-in user session to reset privacy keys.
#>
$base = "C:\Users\LocalUser\Documents\AdminScripts\Logs"
New-Item -ItemType Directory -Force -Path $base | Out-Null
$log = Join-Path $base ("UserPrivacyRestore_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 1 /f | Out-File -Append $log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 1 /f | Out-File -Append $log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 1 /f | Out-File -Append $log
Write-Host "Per-user privacy defaults restored for $env:USERNAME"
