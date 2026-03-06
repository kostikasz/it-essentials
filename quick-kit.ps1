# https://github.com/kostikasz

param (
    [Parameter(Mandatory=$false)]
    [Switch]
    $EnableVerbose
)



# Global settings
$Global:VerboseEnabled = $EnableVerbose.IsPresent
$Script:LogFile = Join-Path -Path '.\logs\' -ChildPath "$(Split-Path $PSCommandPath -Leaf) - $(Get-Date -f 'yyyy-MM-dd_HH-mm-ss').log"

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
    Write-Log -Type VERBOSE -Message "Verbose logging is enabled"
}


<# Usage
# With the default values
Write-Log -Message "This is a message"
# Passing values for some parameters
Write-Log -Type Warning -Message "this is a warning message"
# Passing all values for parameters
Write-Log -Path C:\OtherPath -LogName "MyLog.txt" -Type Error -Message This is a error message"
#>


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
[Q] Quit

"
    return Read-Host "Enter choice: " # Function returns the choice
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
       return Read-Host "Enter choice: " # Function returns the choice
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
       return Read-Host "Enter choice: " # Function returns the choice
}

function FixMenu {
       Write-Host "kostikasz IT support quick kit

FIX LIST:
Choose an option:
[1] Old right-click context menu
[2] Coming Soon
[Q] Quit to main menu

       "
       return Read-Host "Enter choice: " # Function returns the choice
}


function Confirm {

    while ($true) {
        Clear-Host
        Write-Host "kostikasz IT support quick kit

Are you sure? Make sure you don't have unsaved work.:
Choose an option:
[Y] Y (Yes)     [N] N (No)

       "
        $choice = Read-Host 'Enter choice'

        switch ($choice.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
                Write-Host "Invalid option."
                Start-Sleep 1
                continue
            }
        }
    }
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
    Clear-Host
    Write-Host "Installing $ReadableAppID"
    if (-not $Global:VerboseEnabled) {
        Write-Log -Message "Installing $ReadableAppID"
    }
    Write-Log -Type VERBOSE -Message "Installing $ReadableAppID via winget install -e --id $AppID --source=$Source"

    winget.exe install -e --id $AppID --source=$Source

    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Successfully installed $ReadableAppID"
        Write-Host "Successfully installed $ReadableAppID, returning to essential app install menu" -ForegroundColor Green
    } elseif (-not $Global:VerboseEnabled) {
        Write-Log -Type ERROR -Message "Failed to install $ReadableAppID, suggesting to retry installation"
        Write-Host "Failed to install $ReadableAppID."
    } else {
        Write-Log -Type VERBOSE -Message "FAILED to install $ReadableAppID via winget with error code $LASTEXITCODE, suggesting to retry installation"
        Write-Host "Failed to install $ReadableAppID."
    }
    Start-Sleep 3
}

function InstallingBrowsers {
    while ($true) {
        Clear-Host
        $option = InstallMenuBrowsers

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Clear-Host
            InstallHandler -AppID "Google.Chrome"
        }
        "2" {
            InstallHandler -AppID "Mozilla.Firefox"
        }
        "3" {
            Clear-Host
            InstallHandler -AppID "Brave.Brave" -ReadableAppID "Brave Browser"
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
        default {
            Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
            Write-Host "Invalid option."
            Start-Sleep 1
            continue
        }
       }
       
    }
}


function InstallingEssentials {
    while ($true) {
        $option = InstallMenu

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Write-Host "Opening browser installation menu"
            InstallingBrowsers
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
        default {
            Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
            Write-Host "Invalid option."
            continue
        }
       }
       
    }
}

function RevertChanges {

    while ($true) {
        Clear-Host
        Write-Host "kostikasz IT support quick kit

Want to revert changes? Make sure you don't have unsaved work:
Choose an option:
[Y] Y (Yes)     [Y] N (No)

       "
        $choice = Read-Host 'Enter choice'

        switch ($choice.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default {
                Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
                Write-Host "Invalid option."
                continue
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
        [Boolean]
        $Revert=$false,

        [Parameter(Mandatory=$true)]
        [string]
        $FixName
    )
    
 
    if (-not (Confirm)) {
        return
    }
    Clear-Host
    # Checking if registery already exists
    Write-Log -Type VERBOSE -Message "Checking if registry already exists by running query at $RegPath"
    $RegStatus=reg.exe query $RegPath
    if ($RegStatus) {
        if (-not $Global:VerboseEnabled) {
            Write-Log -Type ERROR -Message "The fix is already applied."
        }
        Write-Log -Type VERBOSE -Message "The registry already exists. Query outputed $RegStatus"
        Write-Host "ERROR. The fix is already applied." -ForegroundColor Red
        if (RevertChanges) {    # Calling menu for reverting changes
            Write-Log -Message "Reverting $FixName fix."
            Write-Log -Message "Reverting $FixName fix at the request of user"
            Write-Host "Reverting $FixName fix"
            Write-Log -Type VERBOSE -Message "Trying to delete registry at $RegPath"
            reg.exe delete $RegPath /f /ve
            Write-Log -Type VERBOSE -Message "Deleted registry at $RegPath"
            Write-Log -Type VERBOSE -Message "Restarting Windows Explorer"
            Stop-Process -ProcessName explorer -Force #TODO make silent
            Start-Process explorer
            Write-Log -Type VERBOSE -Message "Restarted Windows Explorer"
            Write-Log -Message "SUCCESS, reverted $FixName fix."
            Write-Host "Fix deleted successfully, returning to menu"
        }
    } else {
            #Make it check if the registery edit already exists
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
}

function ApplyFixes {
    while ($true) {
        $option = FixMenu

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
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
        default {
            Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
            Write-Host "Invalid option."
            Start-Sleep 1
            continue
        }
       }
       
    }
}






# Main loop of the starting menu

while ($true) {
    Clear-Host
    $option = ""
    $option = StartingMenu
    if ($option -eq "") {
        Write-Log -Type WARNING -Message "User inputed nothing into the menu prompt, retrying"
        Write-Host "You input nothing."
        Start-Sleep 1
        continue
    }

    switch ($option.ToLower()) {
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
        "q" {
                Write-Log "User quit the script from the menu."
                Write-Host "Goodbye!"
            exit
        }
            default {
            Write-Log -Type WARNING -Message "User inputed an invalid option in the menu, retrying..."
            Write-Host "Invalid option."
            Start-Sleep 1
            return
        }
    }
}
