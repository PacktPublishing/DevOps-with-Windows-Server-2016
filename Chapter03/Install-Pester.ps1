
Param(
  # folder location for storing the pester files
  [string]$tempDownloadPath
  
)
# create a temp folder for downloading pester.zip
New-Item -ItemType Directory -Path "$tempDownloadPath" -Force 

# download pester.zip from Github
Invoke-WebRequest -Uri https://github.com/pester/pester/archive/master.zip -OutFile "$tempDownloadPath\pester.zip"

# files from internet are blocked. unblocking the archive file
Unblock-File -Path "$tempDownloadPath\pester.zip" 

# extracting files from archive file to Welldefined modules folders
Expand-Archive -Path "$tempDownloadPath\pester.zip" -DestinationPath "$env:ProgramFiles\WindowsPowerShell\Modules\" -Force

# renaming the folder from pester-master to pester
Rename-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\Pester-master" -NewName "$env:ProgramFiles\WindowsPowerShell\Modules\Pester" -Force

# test to check if pester module is available
Get-Module -ListAvailable -name pester



