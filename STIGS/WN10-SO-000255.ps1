<#
.SYNOPSIS
    This PowerShell script ensures correct accounts are used on the system for privileged tasks to help mitigate credential theft..

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-09-11
    Last Modified   : 2025-09-11
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000255

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN10-SO-000255).ps1 
#>

# Self-elevate if not already admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

$path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
New-Item -Path $path -Force | Out-Null
New-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser' -PropertyType DWord -Value 0 -Force | Out-Null
$val = (Get-ItemProperty -Path $path -Name 'ConsentPromptBehaviorUser').ConsentPromptBehaviorUser
Write-Host "ConsentPromptBehaviorUser set to $val at $path"
