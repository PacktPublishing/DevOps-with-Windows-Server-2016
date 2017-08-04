
param
(
    [string] $sqlUsername,
    [string] $sqlPassword,
    [string] $sqlServer,
    [string] $databaseName
)

# connection string prefix used by Entity framework
$constrPrefix = "metadata=res://*/Models.PharmacyModel.csdl|`
            res://*/Models.PharmacyModel.ssdl|`
            res://*/Models.PharmacyModel.msl;`
            provider=System.Data.SqlClient;`
            provider connection string='"

# connection string suffix
$constrSuffix = "MultipleActiveResultSets=True;App=EntityFramework';"

# connection string with username and password
# from Azure Key vault
$connectionString =  "Password=$sqlPassword;`
                      Persist Security Info=False;`
                      User ID=$sqlUsername;`
                      Initial Catalog=$databaseName;`
                      Data Source=$sqlServer.database.windows.net;"

# complete connection string
$connectionString = $constrPrefix + $connectionString + $constrSuffix

# loading web.config content
$xml = [XML](Get-Content "C:\inetpub\MVCWebsite\newapp\web.config") 

# loading all connectionstrings from web.config using xPath
$nodes = $xml.SelectNodes("/configuration/connectionStrings/add")

# looping through connectionstrings
foreach($node in $nodes) {
    if($node.name -eq 'medicineEntities')
    {
        # match found for specific connectionstring
        # update the connection string
        $node.SetAttribute("connectionString", $connectionString);
    }
   
}

# save the updated content to web.config
$xml.Save("C:\inetpub\MVCWebsite\newapp\web.config") 


