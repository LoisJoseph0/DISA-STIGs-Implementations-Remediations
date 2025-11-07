<#
.SYNOPSIS
    This PowerShell script ensures all Windows consumer features system-wide are disabled

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-11-06
    Last Modified   : 2025-11-06
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000197

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN11-CC-000197).ps1 
#>

#Ensure the script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this PowerShell script as Administrator." -ForegroundColor Red
    exit
}

# Define the registry path and value
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$valueName = "DisableWindowsConsumerFeatures"
$valueData = 1

# Create the key if it doesn’t exist
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
    Write-Host "Created registry key: $regPath"
}

# Create or update the DWORD value
New-ItemProperty -Path $regPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null
Write-Host "Set $valueName to $valueData successfully under $regPath"

# Optional: force a Group Policy update
gpupdate /force | Out-Null
Write-Host "Policy updated. Remediation complete." -ForegroundColor Green
