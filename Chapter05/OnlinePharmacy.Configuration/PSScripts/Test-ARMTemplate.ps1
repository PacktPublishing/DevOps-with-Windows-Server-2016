

param(
    [string] $ARMTemplatePath,
    [string] $ARMTemplateParametersPath,
    [string] $resourceGroupName,
    [string] $OMSWorkspaceName,
    [string] $deployLocation
)

New-AzureRmResourceGroup -Name $resourceGroupName -Location $deployLocation -Force -Confirm:$false -Verbose

Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName `
              -TemplateFile "$ARMTemplatePath" `
              -TemplateParameterFile `
              "$ARMTemplateParametersPath" `
              -workspaceName "$OMSWorkspaceName" -Mode Incremental `
              -verbose