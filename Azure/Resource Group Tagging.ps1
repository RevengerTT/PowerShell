
$RGName = "MyResourceGroup"
$TagDept = "IT"
$TagCostCenter = "POCSNumber"
$RGOwner = "Adam.Galfskiy"
#Get Resources with Tags
(Get-AzureRmResourceGroup -Name $RGName).Tags
(Get-AzureRmResourceGroup -Tag @{ Dept="$TagDept" }).ResourceGroupName
#Change Single Tags
Set-AzureRmResourceGroup -Name $RGName -Tag @{ Dept="$TagDept"; Owner="$RGOwner" }  
Set-AzureRmResourceGroup -Name $RGName -Tag @{ CostCenter="$TagCostCenter"}
#Add a new tag to existing
$tags = (Get-AzureRmResourceGroup -Name $RGName).Tags
$tags.Add("TagName", "Value") 
Set-AzureRmResourceGroup -Tag $tags -Name $RGName
#Set Tags on all RGs
$groups = Get-AzureRmResourceGroup
foreach ($g in $groups)
{
    Get-AzureRmResource -ResourceGroupName $g.ResourceGroupName | ForEach-Object {
	    Set-AzureRmResource -ResourceId $_.ResourceId -Tag $g.Tags -Force 
	}
}
#Clear all Tags
Set-AzureRmResourceGroup -Tag @{} -Name plaz-prod1-rg

#Add Locks
$LockName = "ProdVMsNoDelete"
New-AzureRmResourceLock -LockName $LockName -LockLevel CanNotDelete -ResourceGroupName $RGName
Get-AzureRmResourceLock -ResourceGroupName $RGName
#Remove Locks
$lockId = (Get-AzureRmResourceLock -ResourceGroupName $RGName).LockId 
Remove-AzureRmResourceLock -LockId $lockId
Remove-AzureRmResourceLock –lockname readonly –resourcegroupname $RGName

#IAM
Get-AzureRmRoleDefinition | FT Name, Description
Get-AzureRmRoleDefinition "Reader"
$MyUser = "user@tenant.onmicrosoft.com"
Get-AzureRmRoleAssignment -SignInName "$MyUser"
Get-AzureRmRoleAssignment -ResourceGroupName $RGName
Get-AzureADGroup -SearchString "Stuff"

New-AzureRmRoleAssignment -ObjectId $groupID -RoleDefinitionName "Owner" -ResourceGroupName "$RGName"
New-AzureRmRoleAssignment -ObjectId $groupID -RoleDefinitionName "Reader" -ResourceGroupName "$RGName"
Get-AzureRmRoleAssignment -ObjectId $groupId -ResourceGroupName "$RGName"

Policy 

New-AzureRmRoleAssignment -ObjectId $groupID -RoleDefinitionName Owner" -ResourceGroupName “plaz-dev-rg"

$rg = Get-AzureRmResourceGroup -Name '$RGName'
$definition = New-AzureRmPolicyDefinition -Name "allowed-locations" -DisplayName "Allowed locations" -description "This policy enables you to restrict the locations your organization can specify when deploying resources. Use to enforce your geo-compliance requirements." -Policy 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-locations/azurepolicy.rules.json' -Parameter 'https://raw.githubusercontent.com/Azure/azure-policy/master/samples/built-in-policy/allowed-locations/azurepolicy.parameters.json' -Mode All
$definition
$assignment = New-AzureRMPolicyAssignment -Name "only East US" -Scope $rg.ResourceId  -listOfAllowedLocations "East US" -PolicyDefinition $definition
$assignment
