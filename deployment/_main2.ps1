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

foreach ($server1 in $appConfig.configuration.server1.add) {
    $myServer1 = $server1.serverName
    $myServer1Pass = $server1.passwd
    Write-Host $myServer1 -ForegroundColor Cyan
}

foreach ($server2 in $appConfig.configuration.server2.add) {
    $myServer2 = $server2.serverName
    $myServer2Pass = $server2.passwd
    Write-Host $myServer2 -ForegroundColor Green
    Write-Host $myServer2Pass -ForegroundColor Green
}

Write-Host "Step 0: config file loaded ... "


# Step 2: Prep for cluster setup

Write-Host "Step 2: Prep for cluster setup ... "

$clusterName = ""
$clusterIp = ""

foreach ($server in $appConfig.configuration.cluster.add) {
    $clusterName = $server.clusterName
    $clusterIp = $server.clusterIp
    Write-Host $clusterName -ForegroundColor Green
    Write-Host $clusterIp -ForegroundColor Green
}


# Step 2.1: Prepare drives

# -------- run in remote ps from management machine 

Write-Host "Step 2.1:  Prepare drives ... "

$serverList = $myServer1, $myServer2

Invoke-Command ($serverList) {
    Update-StorageProviderCache
    Get-StoragePool | ? IsPrimordial -eq $false | Set-StoragePool -IsReadOnly:$false -ErrorAction SilentlyContinue
    Get-StoragePool | ? IsPrimordial -eq $false | Get-VirtualDisk | Remove-VirtualDisk -Confirm:$false -ErrorAction SilentlyContinue
    Get-StoragePool | ? IsPrimordial -eq $false | Remove-StoragePool -Confirm:$false -ErrorAction SilentlyContinue
    Get-PhysicalDisk | Reset-PhysicalDisk -ErrorAction SilentlyContinue
    Get-Disk | ? Number -ne $null | ? IsBoot -ne $true | ? IsSystem -ne $true | ? PartitionStyle -ne RAW | % {
        $_ | Set-Disk -isoffline:$false
        $_ | Set-Disk -isreadonly:$false
        $_ | Clear-Disk -RemoveData -RemoveOEM -Confirm:$false
        $_ | Set-Disk -isreadonly:$true
        $_ | Set-Disk -isoffline:$true
    }
    Get-Disk | Where Number -Ne $Null | Where IsBoot -Ne $True | Where IsSystem -Ne $True | Where PartitionStyle -Eq RAW | Group -NoElement -Property FriendlyName
} | Sort -Property PsComputerName, Count



# Step 2.2: Test cluster configuration

Write-Host "Step 2.2:  Test cluster configuration ... "
# Test-Cluster -Node $serverList -Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"
Test-Cluster -Node $serverList -Include "Storage Spaces Direct", "Inventory", "System Configuration"


# Step 3: Create the cluster

Write-Host "Step 3: Create the cluster ... "

# If the servers are using static IP addresses, modify the following command to reflect the static IP address by adding the following parameter and specifying the IP address: -StaticAddress <X.X.X.X>;.
# create cluster with static ip 

New-Cluster -Name $clusterName -Node $serverList -nostorage -StaticAddres $clusterIp

# A good check to ensure all cluster resources are online:

<#
# run on node 1 or node 2
Write-Host "Step 3: get cluster ... "


Get-Cluster -Name $clusterName | Get-ClusterResource
Get-ClusterNode
Get-ClusterResource
Get-ClusterNetwork
#>


# start the cluster if it's stopped 
Write-Host "Step 3: start cluster ... "
Start-Cluster -Name $clusterName

