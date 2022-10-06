

## 
<#
script: main5.ps1
purpose: 
    Post configuration for Stack HCI cluster 

    Step 0: config file loaded 
    Post config Step 3: Connect and manage Azure Stack HCI registration
        Install Azure Powershell first 
        Register a cluster using PowerShell
        Install the required PowerShell cmdlets on your management computer.
        Set repo as trusted 
        Register AzStackHCI
        View registration status using PowerShell
#>



$invocation = (Get-Variable MyInvocation).Value
$currentDirectory = Split-Path $invocation.MyCommand.Path
Write-Host $currentDirectory

$appConfigFile = [IO.Path]::Combine($currentDirectory, 'appConfig.xml')

$appConfig = New-Object XML
$appConfig.Load($appConfigFile)

$myServer1 = ""
$myServer2 = ""
$myServer1Pass = ""
$myServer2Pass = ""

$myServer1Adapter1 = ""
$myServer1Adapter2 = ""

$myServer2Adapter1 = ""
$myServer2Adapter2 = ""

foreach ($server1 in $appConfig.configuration.server1.add) {
    $myServer1 = $server1.serverName
    $myServer1Pass = $server1.passwd
    $myServer1Adapter1 = $server1.adapter1
    $myServer1Adapter2 = $server1.adapter2

    Write-Host $myServer1 -ForegroundColor Cyan
    Write-Host $myServer1Pass -ForegroundColor Cyan
    Write-Host $myServer1Adapter1 -ForegroundColor Cyan
    Write-Host $myServer1Adapter2 -ForegroundColor Cyan
}

foreach ($server2 in $appConfig.configuration.server2.add) {
    $myServer2 = $server2.serverName
    $myServer2Pass = $server2.passwd
    $myServer2Adapter1 = $server2.adapter1
    $myServer2Adapter2 = $server2.adapter2
    
    Write-Host $myServer2 -ForegroundColor Green
    Write-Host $myServer2Pass -ForegroundColor Green
    Write-Host $myServer2Adapter1 -ForegroundColor Green
    Write-Host $myServer2Adapter2 -ForegroundColor Green
}

Write-Host "Step 0: config file loaded ... "

$clusterName = ""
$clusterIp = ""
$intentName = ""
$volumeName = ""

foreach ($server in $appConfig.configuration.cluster.add) {
    $clusterName = $server.clusterName
    $clusterIp = $server.clusterIp
    $intentName = $server.intName
    $volumeName = $server.volumeName
    Write-Host $clusterName -ForegroundColor Green
    Write-Host $clusterIp -ForegroundColor Green
    Write-Host $intentName -ForegroundColor Green
    Write-Host $volumeName -ForegroundColor Green
}


$resourceGroup = ""
$location = ""
$storageAccName = ""

foreach ($witness in $appConfig.configuration.witness.add) {
    $resourceGroup = $witness.resourceGroup
    $location = $witness.location
    $storageAccName = $witness.storageAccName
    Write-Host $resourceGroup -ForegroundColor Green
    Write-Host $location -ForegroundColor Green
    Write-Host $storageAccName -ForegroundColor Green
}

$subscriptionId = ""
$hciRgName = ""

foreach ($azureConfig in $appConfig.configuration.azureConfig.add) {
    $subscriptionId = $azureConfig.subscriptionId
    $hciRgName = $azureConfig.hciRgName
    Write-Host $subscriptionId -ForegroundColor Green
    Write-Host $hciRgName -ForegroundColor Green
}

# Post config Step 3: Connect and manage Azure Stack HCI registration


Write-Host "Post config Step 3: Connect and manage Azure Stack HCI registration..."

# install Azure Powershell first 
New-AzRoleDefinition -InputFile customHCIRole.json

$user = get-AzAdUser -DisplayName "System Administrator"
$role = Get-AzRoleDefinition -Name "Azure Stack HCI registration role"
New-AzRoleAssignment -ObjectId $user.Id -RoleDefinitionId $role.Id -Scope /subscriptions/$subscriptionId

# Register a cluster using PowerShell
# Install the required PowerShell cmdlets on your management computer.
# set repo as trusted 
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Az.StackHCI

Register-AzStackHCI  -SubscriptionId $subscriptionId -ComputerName $myServer1 -ResourceGroupName $hciRgName

# View registration status using PowerShell
Write-Host "Post config Step 3 : Check register Portal resutls ..."
$user = $myServer1 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force
$ScriptBlockContent = {    Get-AzureStackHCI }
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent 



