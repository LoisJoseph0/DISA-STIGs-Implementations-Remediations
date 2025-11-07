<#
.SYNOPSIS
    This PowerShell script ensures HTTP-based printing is turned off across the system by enforcing
    DisableHTTPPrinting=1 via policy (with optional WebPnP/WSD blocking) and applying it immediately..

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-11-07
    Last Modified   : 2025-11-07
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000110

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN11-CC-000110).ps1 
#>
# --- Self-elevate without here-strings ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    $temp = Join-Path $env:TEMP 'Set-DisableHTTPPrinting.elevated.ps1'
    $lines = @(
        '$ErrorActionPreference = "Stop"'
        '$base = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers"'
        'if (-not (Test-Path $base)) { New-Item -Path $base -Force | Out-Null }'
        'New-ItemProperty -Path $base -Name "DisableHTTPPrinting" -PropertyType DWord -Value 1 -Force | Out-Null'
        '# Optional companions; comment out if not needed'
        'New-ItemProperty -Path $base -Name "DisableWebPnPDownload" -PropertyType DWord -Value 1 -Force | Out-Null'
        'New-ItemProperty -Path $base -Name "DisableWSD" -PropertyType DWord -Value 1 -Force | Out-Null'
        'try { Disable-WindowsOptionalFeature -Online -FeatureName Printing-InternetPrinting-Client -NoRestart -ErrorAction Stop | Out-Null } catch {}'
        'try { gpupdate /target:computer /force | Out-Null } catch {}'
        'Stop-Service Spooler -Force'
        'Start-Service Spooler'
        '$vals = Get-ItemProperty -Path $base'
        '$feat = Get-WindowsOptionalFeature -Online -FeatureName Printing-InternetPrinting-Client'
        'Write-Host "`n[Policy Values]"'
        '"DisableHTTPPrinting      = {0}" -f $vals.DisableHTTPPrinting'
        '"DisableWebPnPDownload    = {0}" -f $vals.DisableWebPnPDownload'
        '"DisableWSD               = {0}" -f $vals.DisableWSD'
        'Write-Host "`n[Feature State]"'
        '"Internet Printing Client = {0}" -f $feat.State'
    )
    Set-Content -Path $temp -Value $lines -Encoding UTF8
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        '-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$temp`""
    ) | Out-Null
    return
}

# --- Already elevated: do the work directly ---
$ErrorActionPreference = "Stop"
$base = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers'
if (-not (Test-Path $base)) { New-Item -Path $base -Force | Out-Null }

New-ItemProperty -Path $base -Name 'DisableHTTPPrinting' -PropertyType DWord -Value 1 -Force | Out-Null
# Optional companions; comment out if not needed
New-ItemProperty -Path $base -Name 'DisableWebPnPDownload' -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $base -Name 'DisableWSD' -PropertyType DWord -Value 1 -Force | Out-Null

try { Disable-WindowsOptionalFeature -Online -FeatureName Printing-InternetPrinting-Client -NoRestart -ErrorAction Stop | Out-Null } catch {}
try { gpupdate /target:computer /force | Out-Null } catch {}
Stop-Service Spooler -Force
Start-Service Spooler

$vals = Get-ItemProperty -Path $base
$feat = Get-WindowsOptionalFeature -Online -FeatureName Printing-InternetPrinting-Client
Write-Host "`n[Policy Values]"
"DisableHTTPPrinting      = {0}" -f $vals.DisableHTTPPrinting
"DisableWebPnPDownload    = {0}" -f $vals.DisableWebPnPDownload
"DisableWSD               = {0}" -f $vals.DisableWSD
Write-Host "`n[Feature State]"
"Internet Printing Client = {0}" -f $feat.State
