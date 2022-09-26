
# Using Windows PowerShell
## You can either run PowerShell locally in an RDP session on a host server, or you can run PowerShell remotely from a management computer. 

# Have 2 Stack HCI single server installed 
## First we will connect to each of the servers, join them to a domain (the same domain the management computer is in), and install required roles and features.

# When running PowerShell commands from your management PC, you might get an error like WinRM cannot process the request. To fix this, use PowerShell to add each server to the Trusted Hosts list on your management computer. This list supports wildcards, like Server* for example.

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value Server1 -Force




# ----------------------------------------------------------------------------------


# Step 1.1: Connect to the servers

$myServer = "DELLHCINODES01"
$user = "$myServer\Administrator"

$passwd = convertto-securestring -AsPlainText -Force -String "P@ssw0rd"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
Enter-PSSession -ComputerName $myServer -Credential $cred

# Step 1.2: Join the domain and add domain accounts

# In each server Enter-PSSession session 
$myServer = "DELLHCINODES01"
$domainName = "mtctpe.com"
$user = "mtctpe\administrator"
$passwd = convertto-securestring -AsPlainText -Force -String "WS2019Rocks"
$credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd

Add-Computer -DomainName $domainName -Credential $credDomain -Restart -Force
# Add-LocalGroupMember -Group "Administrators" -Member "king@contoso.local"

# Step 1.3: Install roles and features

$myServer = "DELLHCINODES01"
Install-WindowsFeature -ComputerName $myServer -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools

# $ServerList = "Server1", "Server2", "Server3", "Server4"
$ServerList = "DELLHCINODES01"
Restart-Computer -ComputerName $ServerList -WSManAuthentication Kerberos


# ----------------------------------------------------------------------------------

# Repeat for Server 2 

# Step 1.1: Connect to the servers

$myServer = "DELLHCINODES02"
$user = "$myServer\Administrator"
$passwd = convertto-securestring -AsPlainText -Force -String "P@ssw0rd"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
Enter-PSSession -ComputerName $myServer -Credential $cred


# Step 1.2: Join the domain and add domain accounts

$myServer = "DELLHCINODES02"
$domainName = "mtctpe.com"
$user = "mtctpe\administrator"
$passwd = convertto-securestring -AsPlainText -Force -String "WS2019Rocks"
$credDomain = new-object -typename System.Management.Automation.PSCredential -argumentlist $user,$passwd
Add-Computer -DomainName $domainName -Credential $credDomain -Restart -Force

# Step 1.3: Install roles and features

$myServer = "DELLHCINODES02"
Install-WindowsFeature -ComputerName $myServer -Name "BitLocker", "Data-Center-Bridging", "Failover-Clustering", "FS-FileServer", "FS-Data-Deduplication", "Hyper-V", "Hyper-V-PowerShell", "RSAT-AD-Powershell", "RSAT-Clustering-PowerShell", "NetworkATC", "Storage-Replica" -IncludeAllSubFeature -IncludeManagementTools

$ServerList = "DELLHCINODES02"
Restart-Computer -ComputerName $ServerList -WSManAuthentication Kerberos

# ----------------------------------------------------------------------------------


# Step 2: Prep for cluster setup

# run in each server for sanitity check 

# Use Get-ClusterNode to show all nodes:
Get-ClusterNode

# Use Get-ClusterResource to show all cluster nodes:
Get-ClusterResource

# Use Get-ClusterNetwork to show all cluster networks:
Get-ClusterNetwork

#　Step 2.1: Prepare drives

    # -------- run in remote ps from management machine 


# Before you enable Storage Spaces Direct, ensure your permanent drives are empty. Run the following script to remove any old partitions and other data.
# Fill in these variables with your values
$ServerList = "DELLHCINODES01", "DELLHCINODES02"

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

    # -------- run in remote ps from management machine 

    # In this step, you'll ensure that the server nodes are configured correctly to create a cluster.
Test-Cluster -Node $ServerList -Include "Storage Spaces Direct", "Inventory", "Network", "System Configuration"

# Step 3: Create the cluster

# If the servers are using static IP addresses, modify the following command to reflect the static IP address by adding the following parameter and specifying the IP address: -StaticAddress <X.X.X.X>;.

$ClusterName="cluster1" 

# New-Cluster -Name $ClusterName –Node $ServerList –nostorage

# create cluster with static ip 

New-Cluster -Name $ClusterName -Node $ServerList -nostorage -StaticAddres 10.17.70.53



# A good check to ensure all cluster resources are online:

Get-Cluster -Name $ClusterName | Get-ClusterResource
Get-ClusterNode
Get-ClusterResource
Get-ClusterNetwork

# start the cluster if it's stopped 
Start-Cluster -Name cluster1


# Step 4: Configure host networking


# Step 4.1: Review physical adapters

# *** On one of the cluster nodes, run Get-NetAdapter to review the physical adapters.

# Get-NetAdapter -Name pNIC01, pNIC02 -CimSession (Get-ClusterNode).Name | Select Name, PSComputerName


Get-NetAdapter -Name NIC1, NIC2

# rename if 2 server network adapter names not matching 
Rename-NetAdapter -Name oldName -NewName newName


# Step 4.2: Configure an intent

# Add-NetIntent -Name Cluster_ComputeStorage -Compute -Storage -ClusterName $ClusterName -AdapterName pNIC01, pNIC02

# in each server node

$ClusterName="cluster1" 
Add-NetIntent -Name Cluster_ComputeStorage -Compute -Storage -ClusterName $ClusterName -AdapterName NIC1, NIC2


# Step 4.3: Validate intent deployment

Get-NetIntent -ClusterName $ClusterName

Get-NetIntentStatus -ClusterName $ClusterName -Name Cluster_ComputeStorage
Get-VMSwitch -CimSession (Get-ClusterNode).Name | Select Name, ComputerName




# Step 6: Enable Storage Spaces Direct


# The following command enables Storage Spaces Direct on a multi-node cluster. You can also specify a friendly name for a storage pool, as shown here:
Enable-ClusterStorageSpacesDirect -PoolFriendlyName "$ClusterName Storage Pool" -CimSession $ClusterName

# Here's an example on a single-node cluster, disabling the storage cache:
# Enable-ClusterStorageSpacesDirect -CacheState Disabled

# To see the storage pools, use this:

# run in either server node 
# Get-StoragePool -CimSession $session

Get-StoragePool

# -------------------------- End of creating cluster



# Create storage account // how to do that in PS? 

# Create a cloud witness using Windows PowerShell

Set-ClusterQuorum –Cluster "Cluster1" -CloudWitness -AccountName "AzureStorageAccountName" -AccessKey "AzureStorageAccountAccessKey"

Set-ClusterQuorum -FileShareWitness "\\fileserver\share" -Credential (Get-Credential)


