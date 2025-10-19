

---



\# 🧭 Windows Privacy Toolkit



Centralized PowerShell toolkit for locking down and auditing Windows 11 privacy settings.

These are written to be ran from a Windows 11 local user setup as an administrator and the user's name is LocalUser. 
They will try to create folders for logs based on that so if you have it differently, you will need to modify the scripts to change the name LocalUser to whatever your local admin account is.




---



\## 📁 Folder Structure

C:\\Users\\LocalUser\\Documents\\AdminScripts

│

├── Run-PrivacyToolkit.ps1                ← Main launcher (menu)

├── Apply-WindowsPrivacyBaseline.ps1      ← System-wide lockdown

├── Restore-WindowsPrivacyDefaults.ps1    ← Rollback to defaults

├── Apply-UserPrivacy.ps1                 ← Per-user registry hardening

├── Restore-UserPrivacy.ps1               ← Per-user rollback

├── Audit-WindowsTelemetry.ps1            ← Network observation \& logging

└── Logs\\                                 ← Output logs (auto-created)


---



\## ⚙️ Usage



1\. \*\*Open PowerShell as Administrator\*\*  

Right-click → “Run as Administrator” or use 'sudo pwsh' from regular powershell



2\. \*\*Run the Launcher\*\*



 ```powershell

cd "C:\\Users\\LocalUser\\Documents\\AdminScripts"

.\\Run-PrivacyToolkit.ps1

```



3\. \*\*Select a Function\*\*



| Option | Function               | Requires Admin | Description                                                                      |

| ------ | ---------------------- | -------------- | -------------------------------------------------------------------------------- |

| 1      | Apply Privacy Baseline | ✅              | Disables telemetry services, tasks, and sets privacy registry keys for all logged in users |

| 2      | Restore Defaults       | ✅              | Re-enables all services, tasks, and registry defaults                            |

| 3      | Apply User Privacy     | ❌              | Per-user version of the privacy tweaks (HKCU only)                               |

| 4      | Restore User Privacy   | ❌              | Undo user-level changes                                                          |

| 5      | Audit Telemetry        | ✅              | Observes outbound connections for a set time (10–600s)                           |



---



\## 🧩 Notes



\* All logs are saved to:

`C:\\Users\\LocalUser\\Documents\\AdminScripts\\Logs`



\* The \*\*Audit Telemetry\*\* tool accepts a duration between \*\*10–600 seconds\*\* (default \*\*60 seconds\*\*) and highlights potential telemetry or Microsoft network connections.



\* Scripts are \*\*idempotent\*\* — safe to re-run multiple times.



\* To restore default behavior, run option \*\*\[2] Restore Defaults\*\* in the launcher.



---



\## 🧱 Recommended Workflow



1\. Run \*\*\[1] Apply Privacy Baseline\*\* after a clean install or major Windows update.

2\. Run \*\*\[5] Audit Telemetry\*\* to confirm outbound silence.

3\. Apply \*\*\[3] Per-User Privacy\*\* for each new user account.

4\. If any system feature breaks or needs telemetry (e.g., Store diagnostics), use \*\*\[2] Restore Defaults\*\* to revert safely.



---



\## 🧰 Requirements



\* Windows 11 Pro (or higher)

\* PowerShell 7+

\* Administrator privileges (for system-level scripts)



---



\## 🧾 License



All scripts are provided for personal system hardening and auditing.

They modify only documented Windows APIs and registry locations.

Reversible and safe for production environments.





---




