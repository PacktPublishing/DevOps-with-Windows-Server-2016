

param(
    [string] $releaseName,
    [string] $resourceGroupName,
	[string] $testScriptPath,
	[string] $operationTestsPath
    
)


$releaseName
$resourceGroupName
$testScriptPath

Invoke-Pester -Script @{Path = "$testScriptPath"; Parameters = @{ deploymentName = "$releaseName" ; resourceGroupName = "$resourceGroupName" }}

Invoke-Pester -Script @{Path = "$operationTestsPath"; Parameters = @{ deploymentName = "$releaseName" ; resourceGroupName = "$resourceGroupName" }}

