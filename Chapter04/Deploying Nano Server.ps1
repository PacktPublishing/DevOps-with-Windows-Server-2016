
# declaring Resource group name for deploying Nano server
$rgName = "NaNoServerRG"

# testing the correctness of ARM template before deploying it in NaNoServerRG Resource group
# The deployment is incremental and templatefile referes to location of ARM template
Test-AzureRmResourceGroupDeployment -ResourceGroupName $rgName -Mode Incremental -TemplateFile "C:\templates\azuredeploy.json" -Verbose

# deploying ARM template in NaNoServerRG Resource group
# The deployment is incremental and templatefile referes to location of ARM template
New-AzureRmResourceGroupDeployment -Name "Deployment1" -ResourceGroupName $rgName -Mode Incremental -TemplateFile "C:\templates\azuredeploy.json" -Verbose

