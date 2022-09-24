
# Using Windows PowerShell
## You can either run PowerShell locally in an RDP session on a host server, or you can run PowerShell remotely from a management computer. 

# Have 2 Stack HCI single server installed 
## First we will connect to each of the servers, join them to a domain (the same domain the management computer is in), and install required roles and features.

# When running PowerShell commands from your management PC, you might get an error like WinRM cannot process the request. To fix this, use PowerShell to add each server to the Trusted Hosts list on your management computer. This list supports wildcards, like Server* for example.

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value Server1 -Force

# Step 1.1: Connect to the servers

Enter-PSSession -ComputerName "Server1" -Credential "Server1\Administrator"

$myServer1 = "Server1"
$user = "$myServer1\Administrator"

Enter-PSSession -ComputerName $myServer1 -Credential $user

# Step 1.2: Join the domain and add domain accounts

Enter-PSSession 

Add-Computer -NewName "Server1" -DomainName "contoso.com" -Credential "Contoso\User" -Restart -Force

Add-LocalGroupMember -Group "Administrators" -Member "king@contoso.local"

# Step 1.3: Install roles and features

Install-WindowsFeature -ComputerName "Server1" -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools

# Fill in these variables with your values
$ServerList = "Server1", "Server2", "Server3", "Server4"
$FeatureList = "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica"

# This part runs the Install-WindowsFeature cmdlet on all servers in $ServerList, passing the list of features in $FeatureList.
Invoke-Command ($ServerList) {
    Install-WindowsFeature -Name $Using:Featurelist -IncludeAllSubFeature -IncludeManagementTools
}

# restart server 

$ServerList = "Server1", "Server2", "Server3", "Server4"
Restart-Computer -ComputerName $ServerList -WSManAuthentication Kerberos

# Step 2: Prep for cluster setup

# Use Get-ClusterNode to show all nodes:
Get-ClusterNode

# Use Get-ClusterResource to show all cluster nodes:
Get-ClusterResource

# Use Get-ClusterNetwork to show all cluster networks:
Get-ClusterNetwork

#　Step 2.1: Prepare drives


# Fill in these variables with your values
$ServerList = "Server1", "Server2", "Server3", "Server4"

Invoke-Command ($ServerList) {
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

Test-Cluster -Node $ServerList -Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

# Step 3: Create the cluster

# If the servers are using static IP addresses, modify the following command to reflect the static IP address by adding the following parameter and specifying the IP address: -StaticAddress <X.X.X.X>;.

$ClusterName="cluster1" 
New-Cluster -Name $ClusterName –Node $ServerList –nostorage

# A good check to ensure all cluster resources are online:

Get-Cluster -Name $ClusterName | Get-ClusterResource

# Step 4: Configure host networking

# Step 4.1: Review physical adapters

Get-NetAdapter -Name pNIC01, pNIC02 -CimSession (Get-ClusterNode).Name | Select Name, PSComputerName

Rename-NetAdapter -Name oldName -NewName newName

# Step 4.2: Configure an intent

Add-NetIntent -Name Cluster_ComputeStorage -Compute -Storage -ClusterName $ClusterName -AdapterName pNIC01, pNIC02

# Step 4.3: Validate intent deployment

Get-NetIntent -ClusterName $ClusterName

Get-NetIntentStatus -ClusterName $ClusterName -Name Cluster_ComputeStorage

Get-VMSwitch -CimSession (Get-ClusterNode).Name | Select Name, ComputerName


# Step 6: Enable Storage Spaces Direct

Enable-ClusterStorageSpacesDirect -PoolFriendlyName "$ClusterName Storage Pool" -CimSession $ClusterName

Enable-ClusterStorageSpacesDirect -CacheState Disabled

Get-StoragePool -CimSession $session

# https://learn.microsoft.com/en-us/azure-stack/hci/manage/witness

# Create storage account // how to do that in PS? 

# Create a cloud witness using Windows PowerShell

Set-ClusterQuorum –Cluster "Cluster1" -CloudWitness -AccountName "AzureStorageAccountName" -AccessKey "AzureStorageAccountAccessKey"

Set-ClusterQuorum -FileShareWitness "\\fileserver\share" -Credential (Get-Credential)


