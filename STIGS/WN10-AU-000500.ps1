<#
.SYNOPSIS
    This PowerShell script ensures that the maximum size of the Windows Application event log is at least 32768 KB (32 MB).

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-08-19
    Last Modified   : 2025-08-19
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-AU-000500

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN10-AU-000500).ps1 
#>

# Run in an elevated (Administrator) PowerShell
$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\EventLog\Application'

# Ensure the policy key exists
New-Item -Path $path -Force | Out-Null

# Set MaxSize (REG_DWORD). Policy expects KB; 0x00008000 = 32768 KB (32 MB)
New-ItemProperty -Path $path -Name 'MaxSize' -PropertyType DWord -Value 0x00008000 -Force | Out-Null

# (Optional) Verify
Get-ItemProperty -Path $path -Name 'MaxSize' | Format-List

# (Optional) Apply policy now; a reboot may be needed for the Event Log service to fully pick it up
gpupdate /target:computer /force | Out-Null
