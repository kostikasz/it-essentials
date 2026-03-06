# https://github.com/kostikasz


param (
    [Parameter(Mandatory=$false)]
    [Switch]
    $EnableVerbose,

    [Parameter(Mandatory=$false)]
    [Switch]
    $EnableSilent
)

$ErrorActionPreference = 'Stop'

# Global variables
$Global:VerboseEnabled = $EnableVerbose.IsPresent
$Global:SilentEnabled = $EnableSilent.IsPresent
$Script:LogFile = Join-Path -Path '.\logs\' -ChildPath "$(Split-Path $PSCommandPath -Leaf) - $(Get-Date -f 'yyyy-MM-dd_HH-mm-ss').log"
$Global:ExplorerKilled = $false

function MenuHandler {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        $ValidOptions # Should all be passed in lower-case
    )
    
    while ($true) {
        $option = (Read-Host "Enter choice").ToLower().Trim()

        if ($option -eq "") {
            Write-Log -Type WARNING -Message "User inputed nothing into the menu prompt, retrying"
            Write-Host "You input nothing."
            continue
        } elseif ($option -notin $ValidOptions) {
            Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
            Write-Host "Invalid option."
            continue
        } else {
            return $option
        }
    }
}

function Write-Log {
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage = 'Path for the log file. Default value .\logs\')]
        [String]
        $Path = '.\logs\',

        [Parameter(HelpMessage = 'Log file Name. Defaults to script-level variable if set')]
        [String]
        $LogFile = $Script:LogFile,

        [Parameter(Mandatory = $true, HelpMessage = 'Message to add in the log file')]
        [String]
        $Message,

        [Parameter(HelpMessage = 'Type of Message. Default value INFO')]
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'VERBOSE')]
        [String]
        $Type = 'INFO'
    )

    BEGIN {
        # Fall back to generating a name if no script-level variable exists
        if (-not $LogFile) {
            $LogFile = Join-Path -Path $Path -ChildPath "$(Split-Path $PSCommandPath -Leaf) - $(Get-Date -f 'yyyy-MM-dd_HH-mm-ss').log"
        }

        # Ensure folder and file exist
        if (-not (Test-Path -Path (Split-Path $LogFile -Parent))) {
            New-Item -Path (Split-Path $LogFile -Parent) -ItemType Directory -Force | Out-Null
        }
        if (-not (Test-Path -Path $LogFile)) {
            New-Item -Path $LogFile -ItemType File -Force | Out-Null
        }
    }

    PROCESS {
        try {
            # Skip verbose messages unless enabled
            if ($Level -eq "VERBOSE" -and -not $Global:VerboseEnabled) {
            return
            }
            Add-Content -Path $LogFile -Value "$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss') [$Type] $Message"
        }
        catch {
            Write-Error -Message "Could not write into $LogFile"
            Write-Error -Message "Last Error: $($_.Exception.Message)"
        }
    }
}

Write-Log -Message "Script Successfully started"

if ($Global:VerboseEnabled) {
    Write-Log -Message "Verbose logging is enabled"
}

if ($Global:SilentEnabled) {
    Write-Log -Message "Silent mode is enabled"
}

# Check for admin rights
Write-Log -Type VERBOSE -Message "Checking if the user has admin permisssions with Windows Identity"

$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


$user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name



if (-not $isAdmin) {
    Write-Log -Type ERROR -Message "Script is running without administrator permissions, please restart with admin permisions"
    Write-Log -Type VERBOSE -Message "$user doesn't have admin permissions"
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Start-Sleep 2
    exit
} else {
    Write-Log -Type INFO -Message "Script is running with admin permission by user $user"
}



# ALL THE OPTION MENUS

function StartingMenu {
    Write-Host "kostikasz IT support quick kit

Choose an option:
[1] Install essential apps
[2] Install fixes
[3] System information
[Q] Quit

"
    return MenuHandler -ValidOptions '1','2','3','q' # Function returns the choice
}

function InstallMenu {
    Write-Host "kostikasz IT support quick kit

ESSENTIAL APPS INSTALLATION
Choose an option:
[1] Browsers
[2] Work apps
[3] Antivirus
[4] Other
[Q] Quit to main menu

"
    return MenuHandler -ValidOptions '1','2','3','4','q' # Function returns the choice
}

function InstallMenuBrowsers {
    Write-Host "kostikasz IT support quick kit

BROWSERS INSTALLATION
Choose an option:
[1] Google Chrome
[2] Mozilla Firefox
[3] Brave
[Q] Quit to main menu

"
    return MenuHandler -ValidOptions '1','2','3','q' # Function returns the choice
}

function FixMenu {
       Write-Host "kostikasz IT support quick kit

FIX LIST:
Choose an option:
[1] Old right-click context menu
[2] Coming Soon
[Q] Quit to main menu

"
    return MenuHandler -ValidOptions '1','2','q' # Function returns the choice
}

function SystemMenu {
           Write-Host "kostikasz IT support quick kit

System info module:
Choose an option:
[1] OS info
[2] CPU info
[3] RAM info
[4] Disk space info
[5] Format system info into a file
[Q] Quit to main menu

"
    return MenuHandler -ValidOptions '1','2','3','4','5','q' # Function returns the choice
    
}

function ConfirmPrompt {
    Write-Host "kostikasz IT support quick kit

Are you sure? Make sure you don't have unsaved work.:
Choose an option:
[Y] Y (Yes)     [N] N (No)

"
    return MenuHandler -ValidOptions 'y','n' # Function returns the choice
}

function RevertChanges {

    Write-Host "kostikasz IT support quick kit

Want to revert changes? Make sure you don't have unsaved work:
Choose an option:
[Y] Y (Yes)     [N] N (No)

"
    return MenuHandler -ValidOptions 'y','n' # Function returns the choice
}


function InstallHandler {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $AppID,

        [Parameter(Mandatory=$false)]
        [ValidateSet('winget', 'msstore')]
        [String]
        $Source = 'winget',

        [Parameter(Mandatory=$false)]
        [String]
        $ReadableAppID = $AppID.Replace("."," ")
    )

    $exitMessages = @{
    0          = $null   # Success
    -1978335212 = "The installer was cancelled or interrupted. Please try again."
    -1978335189 = "'$ReadableAppID' is already installed and up to date."
    -1978335203 = "'$ReadableAppID' is already installed and up to date."
    -1978335191 = "There are multiple packages matching '$AppID'. Try narrowing the source or using the full package ID."
    -1978335215 = "Insufficient permissions. Contact your system administrator."
    -1978335180 = "Download failed. Check your internet connection and try again."
    -1978335179 = "The installer hash did not match. The package may be corrupted or tampered with."
    -1978335163 = "Disk space is insufficient to install '$ReadableAppID'."
    }

    $warningCodes = @(-1978335189, -1978335203)

    Clear-Host
    Write-Host "Installing $ReadableAppID"
    if (-not $Global:VerboseEnabled) {
        Write-Log -Message "Installing $ReadableAppID"
    }

    if ($Global:SilentEnabled) {
        Write-Log -Type VERBOSE -Message "Installing $ReadableAppID via winget install -e --id $AppID --source=$Source > $null 2>&1"
        winget.exe install -e --id $AppID --source=$Source > $null 2>&1
    } else {
        Write-Log -Type VERBOSE -Message "Installing $ReadableAppID via winget install -e --id $AppID --source=$Source"
        winget.exe install -e --id $AppID --source=$Source
    }

    $friendly_message=$exitMessages[$LASTEXITCODE]

    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Successfully installed $ReadableAppID"
        Write-Host "Successfully installed $ReadableAppID, returning to essential app install menu" -ForegroundColor Green
    } elseif ($friendly_message) {
        $logType = if ($LASTEXITCODE -in $warningCodes) { 'WARNING' } else { 'ERROR' }
        if (-not $Global:VerboseEnabled) {
            Write-Log -Type $logType -Message "Failed to install $ReadableAppID. $friendly_message"
        }
        Write-Log -Type VERBOSE -Message "FAILED to install $ReadableAppID via winget with error code $LASTEXITCODE. $friendly_message"
        Write-Warning "Failed to install $ReadableAppID. $friendly_message"
    } else {
        if (-not $Global:VerboseEnabled) {
            Write-Log -Type $logType -Message "Failed to install $ReadableAppID. Unknown error code: $LASTEXITCODE"
        }
        Write-Log -Type VERBOSE -Message "FAILED to install $ReadableAppID via winget. Unknown error code: '$LASTEXITCODE'. Please submit an issue."
        Write-Warning "Failed to install $ReadableAppID. Unknown error code: $LASTEXITCODE"
    }
    Start-Sleep 3
}

function InstallingBrowsers {
    while ($true) {

        switch (InstallMenuBrowsers) {
        "1" {
            InstallHandler -AppID "Google.Chrome"
        }
        "2" {
            InstallHandler -AppID "Mozilla.Firefox"
        }
        "3" {
            InstallHandler -AppID "Brave.Brave" -ReadableAppID "Brave Browser"
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
       }
    }
}


function InstallingEssentials {
    while ($true) {

        switch (InstallMenu) {
        "1" {
            Clear-Host
            Write-Host "Opening browser installation menu"
            InstallingBrowsers
        }
        "2" {
            Clear-Host
            Write-Host "Coming soon" -ForegroundColor Yellow
            continue
        }
        "3" {
            Clear-Host
            Write-Host "Coming soon" -ForegroundColor Yellow
            continue
        }
        "4" {
            Clear-Host
            Write-Host "Coming soon" -ForegroundColor Yellow
            continue
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
       }
    }
}


function RegistryHandler {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $RegPath,

        [Parameter(Mandatory=$false)]
        [string]
        $Revert='n',

        [Parameter(Mandatory=$true)]
        [string]
        $FixName
    )
    
    Clear-Host
 
    if ($Global:SilentEnabled -or (ConfirmPrompt) -eq 'y') {
        # Checking if registery already exists
        Write-Log -Type VERBOSE -Message "Checking if registry already exists by running query at $RegPath"
        $RegStatus=reg.exe query $RegPath
        if ($RegStatus) {
            if (-not $Global:VerboseEnabled) {
                Write-Log -Type ERROR -Message "The fix is already applied."
            }
            Write-Log -Type VERBOSE -Message "The registry already exists. Query outputed'$RegStatus'"
            Write-Warning "The fix is already applied."

            if ($Global:SilentEnabled -or (RevertChanges) -eq 'y') {    # Calling menu for reverting changes
                Write-Log -Message "Reverting $FixName fix."
                Write-Log -Message "Reverting $FixName fix at the request of user"
                Write-Host "Reverting $FixName fix"
                Write-Log -Type VERBOSE -Message "Trying to delete registry at $RegPath"
                try {
                    Write-Log -Type VERBOSE -Message "Deleted registry at $RegPath"
                    Write-Log -Type VERBOSE -Message "Restarting Windows Explorer"
                    $Global:ExplorerKilled = $true
                    Stop-Process -ProcessName explorer -Force #TODO make silent
                    Start-Process explorer
                    $Global:ExplorerKilled = $false
                    Write-Log -Type VERBOSE -Message "Restarted Windows Explorer"
                } finally {
                    if ($Global:ExplorerKilled) {
                        # Explorer was killed but never restarted
                        Write-Log -Type WARNING -Message "Explorer was killed but never restarted, trying to restart..."
                        Start-Process explorer
                        Write-Log -Message "Explorer was restarted"
                    }
                }

                if ($Global:SilentEnabled) {
                    reg.exe delete $RegPath /f /ve | Out-Null
                } else {
                    reg.exe delete $RegPath /f /ve
                }



                Write-Log -Type VERBOSE -Message "Restarted Windows Explorer"
                Write-Log -Message "SUCCESS, reverted $FixName fix."
                Write-Host "Fix deleted successfully, returning to menu"
            }
        } else {
                #Make it check if the registery edit already exists #TODO: FIX NO FALLBACK EXPLORER
                Write-Log -Message "Applying $FixName fix."
                Write-Host "Applying $FixName fix"
                Write-Log -Type VERBOSE -Message "Trying to add registry at $RegPath"
                reg.exe add $RegPath /f /ve
                Write-Log -Type VERBOSE -Message "Added registry at $RegPath" #TODO create check and error handling
                Write-Log -Type VERBOSE -Message "Restarting Windows Explorer"
                Stop-Process -ProcessName explorer -Force #TODO make silent
                Start-Process explorer
                Write-Log -Type VERBOSE -Message "Restarted Windows Explorer"
                Write-Log -Message "SUCCESS, applied $FixName fix."
                Write-Host "Fix applied Successfully, returning to menu"
        }
        Start-Sleep 2
    } else {
        return
    }
 

}

function ApplyFixes {
    while ($true) {

        switch (FixMenu) {
        "1" {
            Clear-Host
            RegistryHandler -RegPath "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -FixName "right-click context menu"
            }
        
        "2" {
            Clear-Host
            Write-Host "Coming soon" -ForegroundColor Yellow
            continue
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
       }

    }
}

function SystemInfo {
    while ($true) {

        switch (SystemMenu) {
        "1" {
            Clear-Host
            GetOS
            }
        
        "2" {
            Clear-Host
            GetCPU
            continue
        }
        "3" {
            Clear-Host
            GetRAM
            continue
        }
        "4" {
            Clear-Host
            GetDisk
            continue
        }
        "5" {
            Clear-Host
            OutputSysInfo
            continue
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
       }

    }
}


# Main loop of the starting menu
Clear-Host

while ($true) {
    
    switch (StartingMenu) {
        "1" {
                Clear-Host
                Write-Host "Opening essential app installation menu"
                InstallingEssentials
        }
        "2" {
                Clear-Host
                Write-Host "Opening fix menu"
                ApplyFixes
        }
        "3" {
                Clear-Host
                Write-Host "Opening system info menu"
                SystemInfo
        }
        "q" {
                Clear-Host
                Write-Log -Message "User quit the script from the menu."
                Write-Host "Goodbye!"
            exit
        }
    }
}
