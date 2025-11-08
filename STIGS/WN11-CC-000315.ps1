<#
.SYNOPSIS
    This PowerShell script ensures .msi installers don’t automatically get admin powers, so they run as a normal user unless you 
    explicitly approve elevation—reducing the chance of malware sneaking in.

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-11-08
    Last Modified   : 2025-11-08
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000315

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN11-CC-000315).ps1 
#>
# Elevate if needed (no here-strings)
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    $temp = Join-Path $env:TEMP 'Set-AlwaysInstallElevated.ps1'
    $lines = @(
        '$ErrorActionPreference = "Stop"'
        '$path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer"'
        'if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }'
        'New-ItemProperty -Path $path -Name "AlwaysInstallElevated" -PropertyType DWord -Value 0 -Force | Out-Null'
        '$val = (Get-ItemProperty -Path $path -Name "AlwaysInstallElevated").AlwaysInstallElevated'
        'Write-Host "AlwaysInstallElevated set to $val at $path"'
        '# Optional: gpupdate /target:computer /force'
    )
    Set-Content -Path $temp -Value $lines -Encoding UTF8
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$temp`""
    ) | Out-Null
    return
}

# Already elevated
$ErrorActionPreference = "Stop"
$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer'
if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
New-ItemProperty -Path $path -Name 'AlwaysInstallElevated' -PropertyType DWord -Value 0 -Force | Out-Null
$val = (Get-ItemProperty -Path $path -Name 'AlwaysInstallElevated').AlwaysInstallElevated
Write-Host "AlwaysInstallElevated set to $val at $path"
# Optional: gpupdate /target:computer /force
