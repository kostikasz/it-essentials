# https://github.com/kostikasz

# Check for admin rights
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    Start-Sleep 1
    exit
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
                Write-Host "Invalid option."
                Start-Sleep 1
            }
        }
    }
}


function InstallingBrowsers {
    while ($true) {
        #Clear-Host
        $option = InstallMenuBrowsers

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Clear-Host
            Write-Host "Installing Google Chrome"
            winget.exe install -e --id Google.Chrome --source=winget
            Write-Host "Succesfully installed Google Chrome, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "2" {
            Clear-Host
            Write-Host "Installing Mozilla Firefox"
            winget.exe install -e --id Mozilla.Firefox --source=winget
            Write-Host "Succesfully installed Mozilla Firefox, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "3" {
            Clear-Host
            Write-Host "Installing Brave"
            winget.exe install -e --id Brave.Brave --source=winget
            Write-Host "Succesfully installed Brave, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "q" {
            Clear-Host
            Write-Host "Returning to main menu"
            return
        }
        default {
            Write-Host "Invalid option."
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
            Write-Host "Invalid option."
        }
       }
       
    }
}

function RevertChanges {

    while ($true) {
        <# Clear-Host #>
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
                Write-Host "Invalid option."
                Start-Sleep 1
            }
        }
    }
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
            <# Clear-Host #>
            switch (Confirm) {
                $true {
                    $fixstatus=reg.exe query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
                    if ($fixstatus)  {
                        Write-Host "Error. The fix is already applied." -ForegroundColor Red
                        if (RevertChanges) {
                            Write-Host "Reverting right-click context menu fix"
                            reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
                            Stop-Process -ProcessName explorer -Force #TODO make silent
                            Clear-Host
                            Write-Host "Fix deleted succesfully, returning to menu"
                            continue
                        } else {
                            Clear-Host
                            Write-Host "Didn't make any changes. Returning to menu"
                            continue
                        }

                    } else {

                        #Make it check if the registery edit already exists
                        Write-Host "Applying right-click context menu fix"
                        reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
                        Stop-Process -ProcessName explorer -Force #TODO make silent
                        Clear-Host
                        Write-Host "Fix applied succesfully, returning to menu"
                        continue
                    }
                    

                }
                default {
                    Clear-Host
                    Write-Host "Cancelled. Returning to fix menu"
                    continue
                } 
            }
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
            Write-Host "Invalid option."
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
                Write-Host "Goodbye!"
            exit
        }
            default {
            Write-Host "Invalid option."
            return
        }
    }
}
