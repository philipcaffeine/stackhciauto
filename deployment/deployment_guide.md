
# Using Windows PowerShell
## You can either run PowerShell locally in an RDP session on a host server, or you can run PowerShell remotely from a management computer. 

# Have 2 Stack HCI single server installed 
## First we will connect to each of the servers, join them to a domain (the same domain the management computer is in), and install required roles and features.

# When running PowerShell commands from your management PC, you might get an error like WinRM cannot process the request. To fix this, use PowerShell to add each server to the Trusted Hosts list on your management computer. This list supports wildcards, like Server* for example.

Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value Server1 -Force


# ----------------------------------------------------------------------------------


# Step 1.1: Connect to the servers



# Step 1.2: Join the domain and add domain accounts

# In each server Enter-PSSession session 

# Step 1.3: Install roles and features



# ----------------------------------------------------------------------------------

# Repeat for Server 2 

# Step 1.1: Connect to the servers



# Step 1.2: Join the domain and add domain accounts


# Step 1.3: Install roles and features


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


# Step 2.2: Test cluster configuration


# Step 3: Create the cluster

# If the servers are using static IP addresses, modify the following command to reflect the static IP address by adding the following parameter and specifying the IP address: -StaticAddress <X.X.X.X>;.


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
