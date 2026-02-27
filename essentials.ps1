# Check for admin rights
<# $isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)


if (-not $isAdmin) {
    Write-Host "Please run this script as Administrator." -ForegroundColor Red
    exit
}
 #>


function StartingMenu {
    Write-Host "

kostikasz IT support quick kit

Choose an option:
[1] Install essential apps
[2] Install fixes
[Q] Quit

"
    return Read-Host "Enter choice: "
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
       return Read-Host "Enter choice: "
}

function InstallingEssentials {
    while ($true) {
        Write-Host $option
        $option = InstallMenu

        if ($option -eq "") {
            Write-Host "You input nothing."
            Start-Sleep 1
            continue
        }


        switch ($option.ToLower()) {
        "1" {
            Write-Host "Installing essential apps..."
        }
        "2" {
            Write-Host "Applying fixes..."
        }
        "q" {
            Write-Host "Returning to main menu"
            continue
        }
        default {
            Write-Host "Invalid option."
        }
       }
       break
    }
}

# Main loop

while ($true) {
    $option = ""
    $option = StartingMenu
    if ($option -eq "") {
        Write-Host "You input nothing."
        Start-Sleep 1
        continue
    }

    switch ($option.ToLower()) {
        "1" {
              Write-Host "Opening installation menu"
              InstallingEssentials
        }
        "2" {
             Write-Host "Applying fixes..."
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
