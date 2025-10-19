<#
  Apply-UserPrivacy.ps1
  Run inside any logged-in user session to set per-user privacy keys.
#>
$base = "C:\Users\LocalUser\Documents\AdminScripts\Logs"
New-Item -ItemType Directory -Force -Path $base | Out-Null
$log = Join-Path $base ("UserPrivacyApply_{0:yyyyMMdd_HHmmss}.log" -f (Get-Date))

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v ContentDeliveryAllowed /t REG_DWORD /d 0 /f | Out-File -Append $log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f | Out-File -Append $log
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy" /v TailoredExperiencesWithDiagnosticDataEnabled /t REG_DWORD /d 0 /f | Out-File -Append $log
Write-Host "Per-user privacy keys applied for $env:USERNAME"
