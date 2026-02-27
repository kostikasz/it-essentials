# Check for admin rights
<# $isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    exit
}
 #>


# ALL THE OPTION MENUS

function StartingMenu {
    Write-Host "

kostikasz IT support quick kit

Choose an option:
[1] Install essential apps
[2] Install fixes
[Q] Quit

"
    return Read-Host "Enter choice: " # Function returns the choice
}

function InstallMenu {
    Write-Host "
kostikasz IT support quick kit

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
       Write-Host "
kostikasz IT support quick kit

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
       Write-Host "
kostikasz IT support quick kit

FIX LIST:
Choose an option:
[1] Old right-click context menu
[2] Coming Soon
[Q] Quit to main menu

       "
       return Read-Host "Enter choice: " # Function returns the choice
}




function InstallingBrowsers {
    while ($true) {
        #Clear-Host
        Write-Host $option
        $option = InstallMenuBrowsers

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Write-Host "Installing Google Chrome"
            winget.exe install -e --id Google.Chrome --source=winget
            Write-Host "Succesfully installed Google Chrome, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "2" {
            Write-Host "Installing Mozilla Firefox"
            winget.exe install -e --id Mozilla.Firefox --source=winget
            Write-Host "Succesfully installed Mozilla Firefox, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "3" {
            Write-Host "Installing Brave"
            winget.exe install -e --id Brave.Brave --source=winget
            Write-Host "Succesfully installed Brave, returning to essential app install menu" -ForegroundColor Green
            return
        }
        "q" {
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
        #Clear-Host
        Write-Host $option
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
            Write-Host "Coming soon"
            return
        }
        "q" {
            Write-Host "Returning to main menu"
            return
        }
        default {
            Write-Host "Invalid option."
        }
       }
       
    }
}

function ApplyFixes {
    while ($true) {
        #Clear-Host
        Write-Host $option
        $option = FixMenu

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Write-Host "Applying right-click context menu fix"
            reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
            Stop-Process -ProcessName explorer -Force #TODO make silent
            Write-Host "Fix applied succesfully, returning to menu"
        }
        "2" {
            Write-Host "Coming soon"
            return
        }
        "q" {
            Write-Host "Returning to main menu"
            return
        }
        default {
            Write-Host "Invalid option."
        }
       }
       
    }
}






# Main loop of the starting menu

while ($true) {
    <# Clear-Host #>

    $option = ""
    $option = StartingMenu
    if ($option -eq "") {
        Write-Host "You input nothing."
        Start-Sleep 1
        continue
    }

    switch ($option.ToLower()) {
        "1" {
                Write-Host "Opening essential app installation menu"
                InstallingEssentials
        }
        "2" {
                Write-Host "Opening fix menu"
                ApplyFixes
        }
        "q" {
                Write-Host "Goodbye!"
            exit
        }
            default {
            Write-Host "Invalid option."
        }
    }
}
