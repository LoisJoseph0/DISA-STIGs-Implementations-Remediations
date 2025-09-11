<#
.SYNOPSIS
    This PowerShell script ensures that User Account Control must, at minimum, prompt administrators for consent on the secure desktop).

.NOTES
    Author          : Lois Joseph
    LinkedIn        : linkedin.com/in/lois-joseph/
    GitHub          : github.com/LoisJoseph0
    Date Created    : 2025-08-20
    Last Modified   : 2025-08-20
    Version         : 1.0
    CVEs            : N/A
    Plugin IDs      : N/A
    STIG-ID         : WN10-SO-000250

.TESTED ON
    Date(s) Tested  : 
    Tested By       : 
    Systems Tested  : 
    PowerShell Ver. : 

.USAGE
    Put any usage instructions here.
    Example syntax:
    PS C:\> .\__remediation_template(STIG-ID-WN10-SO-000250).ps1 
#>

# Configure HKLM\...\Policies\System and subkeys as specified

$base = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
New-Item -Path $base -Force | Out-Null

# --- DWORD values ---
$dwords = @{
  'ConsentPromptBehaviorAdmin' = 0x00000002
  'ConsentPromptBehaviorUser'  = 0x00000003
  'DSCAutomationHostEnabled'   = 0x00000002
  'EnableCursorSuppression'    = 0x00000001
  'EnableFullTrustStartupTasks'= 0x00000002
  'EnableInstallerDetection'   = 0x00000001
  'EnableLUA'                  = 0x00000001
  'EnableSecureUIAPaths'       = 0x00000001
  'EnableUIADesktopToggle'     = 0x00000000
  'EnableUwpStartupTasks'      = 0x00000002
  'EnableVirtualization'       = 0x00000001
  'PromptOnSecureDesktop'      = 0x00000001
  'SupportFullTrustStartupTasks' = 0x00000001
  'SupportUwpStartupTasks'     = 0x00000001
  'ValidateAdminCodeSignatures'= 0x00000000
  'dontdisplaylastusername'    = 0x00000000
  'scforceoption'              = 0x00000000
  'shutdownwithoutlogon'       = 0x00000001
  'undockwithoutlogon'         = 0x00000001
}

foreach ($name in $dwords.Keys) {
  New-ItemProperty -Path $base -Name $name -PropertyType DWord -Value $dwords[$name] -Force | Out-Null
}

# --- String values ---
$strings = @{
  'legalnoticecaption' = ''
  'legalnoticetext'    = ''
}

foreach ($name in $strings.Keys) {
  New-ItemProperty -Path $base -Name $name -PropertyType String -Value $strings[$name] -Force | Out-Null
}

# --- Subkeys creation ---
$paths = @(
  "$base\Audit",
  "$base\UIPI",
  "$base\UIPI\Clipboard",
  "$base\UIPI\Clipboard\ExceptionFormats"
)
foreach ($p in $paths) { New-Item -Path $p -Force | Out-Null }

# --- Clipboard ExceptionFormats DWORDs ---
$clipPath = "$base\UIPI\Clipboard\ExceptionFormats"
$clip = @{
  'CF_BITMAP'      = 0x00000002
  'CF_DIB'         = 0x00000008
  'CF_DIBV5'       = 0x00000011
  'CF_OEMTEXT'     = 0x00000007
  'CF_PALETTE'     = 0x00000009
  'CF_TEXT'        = 0x00000001
  'CF_UNICODETEXT' = 0x0000000d
}
foreach ($name in $clip.Keys) {
  New-ItemProperty -Path $clipPath -Name $name -PropertyType DWord -Value $clip[$name] -Force | Out-Null
}

# Optional: show configured values
Get-ItemProperty -Path $base |
  Select-Object ConsentPromptBehaviorAdmin,ConsentPromptBehaviorUser,EnableLUA,PromptOnSecureDesktop,EnableVirtualization,EnableInstallerDetection,EnableSecureUIAPaths,EnableUwpStartupTasks,EnableFullTrustStartupTasks,SupportUwpStartupTasks,SupportFullTrustStartupTasks,ValidateAdminCodeSignatures,dontdisplaylastusername,scforceoption,shutdownwithoutlogon,undockwithoutlogon,legalnoticecaption,legalnoticetext |
  Format-List

Write-Host "`nRegistry updated. A reboot is recommended for UAC-related settings to fully apply."
