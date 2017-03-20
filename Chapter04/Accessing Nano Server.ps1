# declaring public Ip address and remoting port of Nano Server
# provide your own ip here
$hostName= "11.111.11.111"
$winrmPort = "5986"

# username for connecting to Nano Server
# provide your own username here
$username = "serveradminname"

# converting password into a secure string
# provide your own password here
$pass = ConvertTo-SecureString -string "samplepassword" -AsPlainText -Force

# constructing a credential object using username and password
$cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $username, $pass

# Configuring powershell remoting session configuration items
$soptions = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 

# remoting interactively into Nano server using its Ip address, credentials, port and session options. A certificate must exist on
# Nano server before port 5986 and ssl switch can be used to connect to it
Enter-PSSession -ComputerName $hostName -Credential $cred -port $winrmPort -SessionOption $soptions -UseSSL


