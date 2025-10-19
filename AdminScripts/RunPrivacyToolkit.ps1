<#
    Run-PrivacyToolkit.ps1
    Interactive launcher for Windows Privacy Toolkit
    Location:  C:\Users\LocalUser\Documents\AdminScripts
    Requires: PowerShell 7+, Administrator for system scripts
#>

$base   = "C:\Users\LocalUser\Documents\AdminScripts"
$logDir = Join-Path $base "Logs"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null

# Menu options
$tools = @(
    @{Num=1; Name="Apply Windows Privacy Baseline"; Script="Apply-WindowsPrivacyBaseline.ps1"},
    @{Num=2; Name="Restore Windows Privacy Defaults"; Script="Restore-WindowsPrivacyDefaults.ps1"},
    @{Num=3; Name="Apply Per-User Privacy Settings"; Script="Apply-UserPrivacy.ps1"},
    @{Num=4; Name="Restore Per-User Privacy Defaults"; Script="Restore-UserPrivacy.ps1"},
    @{Num=5; Name="Audit Windows Telemetry (Network Observer)"; Script="Audit-WindowsTelemetry.ps1"}
)

function Show-Menu {
    Clear-Host
    Write-Host "=== Windows Privacy Toolkit ===`n"
    foreach ($t in $tools) {
        Write-Host ("[{0}] {1}" -f $t.Num, $t.Name)
    }
    Write-Host "`n[0] Exit`n"
}

do {
    Show-Menu
    $choice = Read-Host "Enter number of script to run"
    switch ($choice) {
        1 {
            & (Join-Path $base "Apply-WindowsPrivacyBaseline.ps1")
            Pause
        }
        2 {
            & (Join-Path $base "Restore-WindowsPrivacyDefaults.ps1")
            Pause
        }
        3 {
            & (Join-Path $base "Apply-UserPrivacy.ps1")
            Pause
        }
        4 {
            & (Join-Path $base "Restore-UserPrivacyDefaults.ps1")
            Pause
        }
        5 {
            Write-Host "`n--- Telemetry Audit ---"
            $t = Read-Host "Enter duration in seconds (10–600, default 60)"
            if (-not $t) { $t = 60 }
            if ($t -lt 10)  { $t = 10 }
            if ($t -gt 600) { $t = 600 }
            Write-Host "Running audit for $t seconds...`n"
            & (Join-Path $base "Audit-WindowsTelemetry.ps1") -t $t
            Pause
        }
        0 {
            Write-Host "`nExiting Privacy Toolkit.`n"
            break
        }
        Default {
            Write-Host "`nInvalid selection. Try again.`n"
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne 0)
