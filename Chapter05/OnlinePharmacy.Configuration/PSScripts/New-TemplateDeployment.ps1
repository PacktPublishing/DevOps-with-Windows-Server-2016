

param(
    [string] $ARMTemplatePath,
    [string] $ARMTemplateParametersPath,
    [string] $resourceGroupName,
    [string] $OMSWorkspaceName,
    [string] $skuName = "om",
    [string] $deploymentName = "DefaultName",
	[string] $pullserverRegKey  = "11111111-1111-1111-1111-111111111111"
	
)



New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName `
              -TemplateFile "$ARMTemplatePath" `
              -TemplateParameterFile `
              "$ARMTemplateParametersPath" `
              -workspaceName "$OMSWorkspaceName" -skuName $skuName -pullserverRegKey $pullserverRegKey -Mode Incremental `
              -verbose