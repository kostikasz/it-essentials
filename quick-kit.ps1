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

function Get-MenuChoice {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]
        $validOptions # Should all be passed in lower-case
    )
    
    while ($true) {
        $option = (Read-Host "Enter choice").ToLower().Trim()

        if ($option -eq "") {
            Write-Log -Type WARNING -Message "User inputed nothing into the menu prompt, retrying"
            Write-Host "You input nothing."
            continue
        } elseif ($option -notin $validOptions) {
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
            if ($Type -eq "VERBOSE" -and -not $Global:VerboseEnabled) {
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

function Show-StartMenu {
    Write-Host "kostikasz IT support quick kit

Choose an option:
[1] Install essential apps
[2] Install fixes
[3] Bulk install apps/fixes
[4] System information
[Q] Quit

"
    return Get-MenuChoice -ValidOptions '1','2','3','4','q' # Function returns the choice
}

function Show-InstallMenu {
    Write-Host "kostikasz IT support quick kit

ESSENTIAL APPS INSTALLATION
Choose an option:
[1] Browsers
[2] Work apps
[3] Antivirus
[4] Other
[Q] Quit to main menu

"
    return Get-MenuChoice -ValidOptions '1','2','3','4','q' # Function returns the choice
}

function Show-BulkInstallMenu {
    Write-Host "kostikasz IT support quick kit

BULK INSTALLATION menu
Choose an option:
[1] Install browsers
[2] Apply all fixes
[3] Install full essentials pack
[Q] Quit to main menu

"
    return Get-MenuChoice -ValidOptions '1','2','3','q' # Function returns the choice
}

function Show-InstallMenuBrowsers {
    Write-Host "kostikasz IT support quick kit

BROWSERS INSTALLATION
Choose an option:
[1] Google Chrome
[2] Mozilla Firefox
[3] Brave
[Q] Quit to main menu

"
    return Get-MenuChoice -ValidOptions '1','2','3','q' # Function returns the choice
}

function Show-FixMenu {
       Write-Host "kostikasz IT support quick kit

FIX LIST:
Choose an option:
[1] Old right-click context menu
[2] Show file extensions
[Q] Quit to main menu

"
    return Get-MenuChoice -ValidOptions '1','2','q' # Function returns the choice
}

function Show-SystemMenu {
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
    return Get-MenuChoice -ValidOptions '1','2','3','4','5','q' # Function returns the choice
    
}

function Show-InfoExitMenu {
    Write-Host "To exit enter: [Q]"
    return Get-MenuChoice -ValidOptions 'q' # Function returns the choice
}

function Show-ConfirmPrompt {
    Write-Host "kostikasz IT support quick kit

Are you sure? Make sure you don't have unsaved work.:
Choose an option:
[Y] Y (Yes)     [N] N (No)

"
    return Get-MenuChoice -ValidOptions 'y','n' # Function returns the choice
}

function Show-RevertPrompt {

    Write-Host "kostikasz IT support quick kit

Want to revert changes? Make sure you don't have unsaved work:
Choose an option:
[Y] Y (Yes)     [N] N (No)

"
    return Get-MenuChoice -ValidOptions 'y','n' # Function returns the choice
}


function Invoke-AppInstall {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $appId,

        [Parameter(Mandatory=$false)]
        [ValidateSet('winget', 'msstore')]
        [String]
        $source = 'winget',

        [Parameter(Mandatory=$false)]
        [String]
        $readableAppId = $appId.Replace("."," ")
    )

    $exitMessages = @{
    0          = $null   # Success
    -1978335212 = "The installer was cancelled or interrupted. Please try again."
    -1978335189 = "'$readableAppId' is already installed and up to date."
    -1978335203 = "'$readableAppId' is already installed and up to date."
    -1978335191 = "There are multiple packages matching '$appId'. Try narrowing the source or using the full package ID."
    -1978335215 = "Insufficient permissions. Contact your system administrator."
    -1978335180 = "Download failed. Check your internet connection and try again."
    -1978335179 = "The installer hash did not match. The package may be corrupted or tampered with."
    -1978335163 = "Disk space is insufficient to install '$readableAppId'."
    }

    $warningCodes = @(-1978335189, -1978335203)

    Clear-Host
    Write-Host "Installing $readableAppId"
    if (-not $Global:VerboseEnabled) {
        Write-Log -Message "Installing $readableAppId"
    }

    if ($Global:SilentEnabled) {
        Write-Log -Type VERBOSE -Message "Installing $readableAppId via winget install -e --id $appId --source=$source > $null 2>&1"
        winget.exe install -e --id $appId --source=$source > $null 2>&1
    } else {
        Write-Log -Type VERBOSE -Message "Installing $readableAppId via winget install -e --id $appId --source=$source"
        winget.exe install -e --id $appId --source=$source
    }

    $friendlyMessage = $exitMessages[$LASTEXITCODE]
    $logType = if ($LASTEXITCODE -in $warningCodes) { 'WARNING' } else { 'ERROR' }


    if ($LASTEXITCODE -eq 0) {
        Write-Log -Message "Successfully installed $readableAppId"
        Write-Host "Successfully installed $readableAppId" -ForegroundColor Green
    } elseif ($friendlyMessage) {
        if (-not $Global:VerboseEnabled) {
            Write-Log -Type $logType -Message "Failed to install $readableAppId. $friendlyMessage"
        }
        Write-Log -Type VERBOSE -Message "FAILED to install $readableAppId via winget with error code $LASTEXITCODE. $friendlyMessage"
        Write-Warning "Failed to install $readableAppId. $friendlyMessage"
    } else {
        if (-not $Global:VerboseEnabled) {
            Write-Log -Type $logType -Message "Failed to install $readableAppId. Unknown error code: $LASTEXITCODE"
        }
        Write-Log -Type VERBOSE -Message "FAILED to install $readableAppId via winget. Unknown error code: '$LASTEXITCODE'. Please submit an issue."
        Write-Warning "Failed to install $readableAppId. Unknown error code: $LASTEXITCODE"
    }
    Start-Sleep 3
}

function Install-Browsers {
    while ($true) {

        switch (Show-InstallMenuBrowsers) {
        "1" {
            Invoke-AppInstall -AppId "Google.Chrome"
        }
        "2" {
            Invoke-AppInstall -AppId "Mozilla.Firefox"
        }
        "3" {
            Invoke-AppInstall -AppId "Brave.Brave" -ReadableAppId "Brave Browser"
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
       }
    }
}


function Install-EssentialApps {
    while ($true) {

        switch (Show-InstallMenu) {
        "1" {
            Clear-Host
            Write-Host "Opening browser installation menu"
            Install-Browsers
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


function Invoke-RegistryFix {
    param (
        [Parameter(Mandatory=$true)]
        [String]$RegPath,

        [Parameter(Mandatory=$true)]
        [string]$FixName,


        # For fixes when reverting or applying uses same or different commands than usual
        [Parameter(Mandatory=$false)]
        [string]$ApplyCommand = "add",     

        [Parameter(Mandatory=$false)]
        [string]$RevertCommand = "delete",     



        # New optional params for named values
        [Parameter(Mandatory=$false)]
        [string]$ValueName = "",          # Empty = default (/ve) mode

        [Parameter(Mandatory=$false)]
        [string]$ValueType = "REG_DWORD",

        [Parameter(Mandatory=$false)]
        [string]$ApplyData = "",          # Value when applying fix

        [Parameter(Mandatory=$false)]
        [string]$RevertData = "",          # Value when reverting fix

        [Parameter(Mandatory=$false)]
        [switch]$Silent = $Global:SilentEnabled,

        [Parameter(Mandatory=$false)]
        [switch]$Bulk = $false,

        [Parameter(Mandatory=$false)]
        [switch]$ExplorerRestartBulk = $false
    )
    

    if($Bulk) {$Silent=$true}
    $useNamedValue = $ValueName -ne ""

    Clear-Host

    if ($Silent -or (Show-ConfirmPrompt) -eq 'y') {

        Clear-Host

        if ($useNamedValue) {
            # Check current DWORD value
            $currentVal = (Get-ItemProperty -Path "Registry::$RegPath" -Name $ValueName -ErrorAction SilentlyContinue).$ValueName
            $alreadyApplied = $null -ne $currentVal -and "$currentVal" -eq $ApplyData
        } else {
            $alreadyApplied = Test-Path -Path "Registry::$RegPath"
        }

        if ($alreadyApplied) {
            Write-Warning "The fix is already applied."

            if ($Silent -or (Show-RevertPrompt) -eq 'y') {
                Write-Log -Message "Reverting $FixName fix at the request of user"
                Write-Host "Reverting $FixName fix"

                
                if ($useNamedValue) {
                    # Toggle back to revert value

                    if ($Silent) {
                        reg.exe $RevertCommand $RegPath /v $ValueName /t $ValueType /d $RevertData /f  | Out-Null
                    } else {
                        reg.exe $RevertCommand $RegPath /v $ValueName /t $ValueType /d $RevertData /f
                    }
                } else {

                    if ($Silent) {
                        reg.exe $RevertCommand $RegPath /f | Out-Null
                    } else {
                        reg.exe $RevertCommand $RegPath /f
                    }

                }

                if ($LASTEXITCODE -eq 0) {
                    if ($Bulk) {
                        if ($ExplorerRestartBulk) {
                            Stop-Process -ProcessName explorer -Force
                        }
                    } else {
                        Stop-Process -ProcessName explorer -Force
                    }
                    Stop-Process -ProcessName explorer -Force
                    Write-Log -Message "SUCCESS, reverted $FixName fix."
                    Write-Host -ForegroundColor Green "Fix reverted successfully, returning to menu"
                } else {
                    Write-Log -Type ERROR -Message "Failed to revert $FixName fix."
                    Write-Host -ForegroundColor Red "Fix failed, check logs"
                }
            }
            

        } else {
            Write-Log -Message "Applying $FixName fix."
            Write-Host "Applying $FixName fix"


            if ($useNamedValue) {
                if ($Silent) {
                    reg.exe $ApplyCommand $RegPath /v $ValueName /t $ValueType /d $ApplyData /f | Out-Null
                } else {
                    reg.exe $ApplyCommand $RegPath /v $ValueName /t $ValueType /d $ApplyData /f
                }
            } else {
                if ($Silent) {
                    reg.exe $ApplyCommand $RegPath /f /ve | Out-Null
                } else {
                    reg.exe $ApplyCommand $RegPath /f /ve
                }
            }

            if ($LASTEXITCODE -eq 0) {
                if ($Bulk) {
                    if ($ExplorerRestartBulk) {
                        Stop-Process -ProcessName explorer -Force
                    }
                } else {
                    Stop-Process -ProcessName explorer -Force
                }
                Write-Log -Message "SUCCESS, applied $FixName fix."
                Write-Host -ForegroundColor Green "Fix applied successfully, returning to menu"
            } else {
                Write-Log -Type ERROR -Message "Failed to apply $FixName fix."
                Write-Host -ForegroundColor Red "Fix failed, check logs"
            }

            Start-Sleep 2
        }

    }
}

function Invoke-Fixes {
    while ($true) {

        switch (Show-FixMenu) {
        "1" {
            Clear-Host
            Invoke-RegistryFix -RegPath "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -FixName "right-click context menu"
            }
        
        "2" {
            Clear-Host
            Invoke-RegistryFix -RegPath "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "HideFileExt" -ValueType "REG_DWORD" -ApplyData "0" -RevertData "1" -RevertCommand "add" -FixName "show/hide app extensions"
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
function Get-OSInfo {
    param([Switch]$Raw)
    $data = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, OSArchitecture
    if ($Raw) { return $data }
    $data | Out-Host
    if ((Show-InfoExitMenu) -eq "q") { return }
}

function Get-CPUInfo {
    param([Switch]$Raw)
    $data = Get-CimInstance Win32_Processor |
        Select-Object Name, NumberOfCores, NumberOfLogicalProcessors,
            @{ Name = "MaxClockSpeedGHz"; Expression = { "{0:N2} GHz" -f ($_.MaxClockSpeed / 1000) } }
    if ($Raw) { return $data }
    $data | Out-Host
    if ((Show-InfoExitMenu) -eq "q") { return }
}

function Get-RamInfo {
    param([Switch]$Raw)
    $data = Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, DeviceLocator,
        @{Name="Capacity"; Expression={
            $gb = [math]::Round($_.Capacity / 1GB, 2)
            $tb = [math]::Round($_.Capacity / 1TB, 2)
            if ($tb -ge 1) { "$tb TB" } else { "$gb GB" }
        }},
        @{Name="FormFactor"; Expression={
            switch ($_.FormFactor) {
                8  { "DIMM" }
                12 { "SODIMM" }
                0  { "Unknown" }
                default { "Other ($_)" }
            }
        }},
        Manufacturer, PartNumber, SerialNumber,
        @{Name="Speed (MHz)"; Expression={ "$($_.Speed) MHz" }}
    if ($Raw) { return $data }
    $data | Out-Host
    if ((Show-InfoExitMenu) -eq "q") { return }
}

function Get-DiskInfo {
    param([Switch]$Raw)
    $data = Get-CimInstance Win32_DiskDrive | Select-Object Caption, Description, DeviceID, Model, SerialNumber,
        @{Name="Size"; Expression={
            $gb = [math]::Round($_.Size / 1GB, 2)
            $tb = [math]::Round($_.Size / 1TB, 2)
            if ($tb -ge 1) { "$tb TB" } else { "$gb GB" }
        }}
    if ($Raw) { return $data }
    $data | Out-Host
    if ((Show-InfoExitMenu) -eq "q") { return }
}

function Export-SystemInfo {
    $sysInfoDir = "system_info"

    if (-not (Test-Path -Path $sysInfoDir)) {
        New-Item -Path $sysInfoDir -ItemType Directory -Force | Out-Null
        Write-Log -Message "Created directory '$sysInfoDir'"
        Write-Host "Created folder for system information files: '$sysInfoDir'"
    }

    $files = @{
        "system_info.csv" = { Get-OSInfo -Raw }
        "cpu_info.csv"    = { Get-CPUInfo -Raw }
        "ram_info.csv"    = { Get-RamInfo -Raw }
        "disk_info.csv"   = { Get-DiskInfo -Raw }
    }

    foreach ($fileName in $files.Keys) {
        $filePath = Join-Path $sysInfoDir $fileName

        if (Test-Path -Path $filePath) {
            Write-Log -Type WARNING -Message "File '$filePath' already exists, replacing it"
            Write-Host "Replacing existing file: $fileName" -ForegroundColor Yellow
        }

        & $files[$fileName] | Export-Csv -Path $filePath -NoTypeInformation -Force -Delimiter ';'
    }

    Write-Log -Message "System information outputted to files: system_info.csv, cpu_info.csv, ram_info.csv, disk_info.csv"
    Write-Host "System information outputted to files successfully" -ForegroundColor Green
}

function Invoke-BulkBrowserInstall {
    Clear-Host

    Write-Log -Message "Bulk browser installation starting, requesting confirmation"

    if ((Show-ConfirmPrompt) -eq "y") {
        Write-Log -Message "Bulk browser installation started, confirmed by user"
        Write-Host "Bulk browser installation starting"
        Invoke-AppInstall -AppId "Google.Chrome" -ReadableAppId "Google Chrome"
        $googleChromeInstalled = $LASTEXITCODE -eq 0

        Invoke-AppInstall -AppId "Mozilla.Firefox" -ReadableAppId "Mozilla Firefox"
        $mozillaFirefoxInstalled = $LASTEXITCODE -eq 0

        Invoke-AppInstall -AppId "Brave.Brave" -ReadableAppId "Brave Browser"
        $braveInstalled = $LASTEXITCODE -eq 0

        $downloadedBrowsers = @(
            if ($googleChromeInstalled)  { "Google Chrome" }
            if ($mozillaFirefoxInstalled) { "Mozilla Firefox" }
            if ($braveInstalled)          { "Brave Browser" }
        ) -join ", "

        if (-not $googleChromeInstalled -and -not $mozillaFirefoxInstalled -and -not $braveInstalled) {
            Write-Log -Type ERROR -Message "Bulk browser installation failed, no browsers were downloaded"
            Write-Host -ForegroundColor Red "Bulk browser installation failed, no browsers were downloaded, returning to menu"
            Start-Sleep 1
        } elseif ($googleChromeInstalled -or $mozillaFirefoxInstalled -or $braveInstalled) {
            Write-Log -Message "Bulk browser installation was partly successful, downloaded $downloadedBrowsers"
            Write-Host "Bulk browser installation was partly successful, downloaded $downloadedBrowsers"
            Start-Sleep 1
        } else {
            Write-Log -Message "Bulk browser installation was successful, downloaded $downloadedBrowsers"
            Write-Host -ForegroundColor Green "Bulk browser installation was successful, downloaded $downloadedBrowsers"
        }
    } else {
        Write-Log -Message "Bulk browser installation cancelled by user"
        Write-Host "Cancelled. Returning to menu"
    }
}

function Invoke-BulkFixApply {

    Write-Log -Message "Bulk fix application starting, requesting confirmation"

    if ((Show-ConfirmPrompt) -eq "y") {

        Write-Log -Message "Bulk fix application started, confirmed by user"
        Write-Host "Bulk fix application starting"

        Invoke-RegistryFix -RegPath "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -FixName "right-click context menu" -Bulk
        $contextMenuApplied = $LASTEXITCODE -eq 0
        Invoke-RegistryFix -RegPath "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "HideFileExt" -ValueType "REG_DWORD" -ApplyData "0" -RevertData "1" -RevertCommand "add" -FixName "show/hide app extensions" -Bulk -ExplorerRestartBulk
        $fileExtensionsApplied = $LASTEXITCODE -eq 0

        $appliedFixes = @(
            if ($contextMenuApplied)  { "right-click context menu" }
            if ($fileExtensionsApplied) { "file extensions" }
        ) -join ", "

        if (-not $contextMenuApplied -and -not $fileExtensionsApplied) {
            Write-Log -Type ERROR -Message "Bulk fix application failed, no fixes were applied"
            Write-Host -ForegroundColor Red "Bulk fix application failed, no fixes were applied, returning to menu"
            Start-Sleep 1
        } elseif ($googleChromeInstalled -or $mozillaFirefoxInstalled -or $braveInstalled) {
            Write-Log -Message "Bulk fix application was partly successful, applied $appliedFixes"
            Write-Host "Bulk fix application was partly successful, applied $appliedFixes"
            Start-Sleep 1
        } else {
            Write-Log -Message "Bulk fix application was successful, applied $appliedFixes"
            Write-Host -ForegroundColor Green "Bulk fix application was successful, applied $appliedFixes"
        }

    } else {
        Write-Log -Message "Bulk fix application cancelled by user"
        Write-Host "Cancelled. Returning to menu"
    }
}

function Invoke-BulkEssentialsInstall {
    Clear-Host
    Write-Host "Coming soon" -ForegroundColor Yellow
}

function Show-SystemInfo {
    while ($true) {
        switch (Show-SystemMenu) {
        "1" {
            Clear-Host
            Get-OSInfo
            continue
            }
        
        "2" {
            Clear-Host
            Get-CPUInfo
            continue
        }
        "3" {
            Clear-Host
            Get-RamInfo
            continue
        }
        "4" {
            Clear-Host
            Get-DiskInfo
            continue
        }
        "5" {
            Clear-Host
            Export-SystemInfo
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

function Invoke-BulkInstall {
    while ($true) {
        switch (Show-BulkInstallMenu) {
        "1" {
            Clear-Host
            Invoke-BulkBrowserInstall
            continue
            }
        
        "2" {
            Clear-Host
            Invoke-BulkFixApply
            continue
        }
        "3" {
            Clear-Host
            Invoke-BulkEssentialsInstall
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
    
    switch (Show-StartMenu) {
        "1" {
                Clear-Host
                Write-Host "Opening essential app installation menu"
                Install-EssentialApps
        }
        "2" {
                Clear-Host
                Write-Host "Opening fix menu"
                Invoke-Fixes
        }
        "3" {
                Clear-Host
                Write-Host "Opening bulk install menu"
                Invoke-BulkInstall
        }
        "4" {
                Clear-Host
                Write-Host "Opening system info menu"
                Show-SystemInfo
        }
        "q" {
                Clear-Host
                Write-Log -Message "User quit the script from the menu."
                Write-Host "Goodbye!"
            exit
        }
    }
}
