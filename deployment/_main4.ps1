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


# -------------------------- End of creating cluster ---------------------------------------------------

# --------------------------------------------------------
# Post config Step 1: Set up cluster witness
#　Set up a cluster witness

Write-Host "Post config Step 1 : set up cluster witness ... "

# prepare Azure account 
# Create an Azure storage account

Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Install-Module -Name Az.Storage -AllowClobber
Import-Module Az.Storage
Connect-AzAccount

New-AzResourceGroup -Name $resourceGroup -Location $location
New-AzStorageAccount -ResourceGroupName $resourceGroup `
  -Name $storageAccName `
  -Location $location `
  -SkuName Standard_LRS `
  -Kind StorageV2


# Copy the access key and endpoint URL

$Key = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -Name $storageAccName)[0].Value
Write-Host "storage account key 1 = " $Key

$blobStorageEndpoint = $storageAccName + ".blob.core.windows.net"
Write-Host $blobStorageEndpoint

#Create a cloud witness using Windows PowerShell

Set-ClusterQuorum –Cluster $clusterName -CloudWitness -AccountName $storageAccName -AccessKey $Key


# --------------------------------------------------------

# Post config Step 2 : Create volume

Write-Host "Post config Step 2 : Create volume ..."
$user = $myServer1 + "\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String $myServer1Pass
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value $myServer1 -Force
$ScriptBlockContent = {
    
    $volumeName = $args[0]
    New-Volume -FriendlyName $volumeName -FileSystem CSVFS_ReFS -StoragePoolFriendlyName S2D* -Size 1TB
    Get-StorageTier | Select FriendlyName, ResiliencySettingName, PhysicalDiskRedundancy
}
Invoke-Command -ComputerName $myServer1 -Credential $cred -ScriptBlock $ScriptBlockContent -ArgumentList $volumeName



