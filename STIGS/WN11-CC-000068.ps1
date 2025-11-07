<#
.SYNOPSIS
    This PowerShell script ensures that the Group Policy for Credential Delegation (CredSSP) is enabled so Windows can allow protected 
    credentials to be delegated to approved targets.

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-11-07
    Last Modified   : 2025-11-07
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN11-CC-000068

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN11-CC-000068).ps1 
#>
$path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
New-Item -Path $path -Force | Out-Null
New-ItemProperty -Path $path -Name 'AllowProtectedCreds' -PropertyType DWord -Value 1 -Force | Out-Null
(Get-ItemProperty -Path $path -Name 'AllowProtectedCreds').AllowProtectedCreds
