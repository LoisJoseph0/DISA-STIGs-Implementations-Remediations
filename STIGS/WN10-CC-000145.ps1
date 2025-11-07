<#
.SYNOPSIS
    This PowerShell script ensures the user is prompted for a password on resume from sleep (on battery).

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-09-10
    Last Modified   : 2025-09-10
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-CC-000145

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN10-CC-000145).ps1 
#>

# Self-elevate if not already admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Power\PowerSettings\0e796bdb-100d-47d6-a2d5-f7d2daa51f51'
try {
    New-Item -Path $path -Force | Out-Null
    New-ItemProperty -Path $path -Name 'DCSettingIndex' -PropertyType DWord -Value 1 -Force | Out-Null
    $val = (Get-ItemProperty -Path $path).DCSettingIndex
    Write-Host "DCSettingIndex set to $val at $path"
} catch {
    Write-Error "Failed to set policy: $_"
}
