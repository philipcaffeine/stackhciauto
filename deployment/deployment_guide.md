
### Prepare input parameters for appConfig.xml 

1. Update each parameters in XML

2. List of parameters:


### Variables for appConfig.xml

| XML variable name  | Status                     | Description                                                                                                                                                                                                          |
|------------------------------------------------------------------------------------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| server1                     | :heavy_check_mark:         | XML group of variables for 1st node of host                                     |
| server1 > serverName                    | :heavy_check_mark:         | hostname of server node 1                                     |
| server1 > passwd                    | :heavy_check_mark:         | administrator login password of node 1                                     |
| server1 > adapter1                    | :heavy_check_mark:         | adapter1 name of node 1, the 2 adapters needs to be symmetric, https://learn.microsoft.com/en-us/azure-stack/hci/concepts/host-network-requirements#set                                     |
| server1 > adapter2                    | :heavy_check_mark:         | adapter2 name of node 1, the 2 adapters needs to be symmetric, https://learn.microsoft.com/en-us/azure-stack/hci/concepts/host-network-requirements#set                                    |
| server2                     | :heavy_check_mark:         | XML group of variables for 2nd node of host                                     |
| server2 > serverName                    | :heavy_check_mark:         | hostname of server node 2                                     |
| server2 > passwd                    | :heavy_check_mark:         | administrator login password of node 2                                     |
| server2 > adapter1                    | :heavy_check_mark:         | adapter1 name of node 2, the 2 adapters needs to be symmetric, https://learn.microsoft.com/en-us/azure-stack/hci/concepts/host-network-requirements#set                                     |
| server2 > adapter2                    | :heavy_check_mark:         | adapter2 name of node 2, the 2 adapters needs to be symmetric, https://learn.microsoft.com/en-us/azure-stack/hci/concepts/host-network-requirements#set                                    |
| domain                     | :heavy_check_mark:         | XML group of variables for domain to join                                  |
| domain > domainUser                    | :heavy_check_mark:         | domain controller user for join domain of node1 and 2, for example, abc\administrator                                    |
| domain > domainName                    | :heavy_check_mark:         | domain name, for example, abc.com                                      |
| domain > domainPasswd                    | :heavy_check_mark:         | domain password                                     |
| cluster                     | :heavy_check_mark:         | XML group of variables for cluser to create from 2 nodes                                    |
| cluster > clusterName                    | :heavy_check_mark:         | Cluster Name                                    |
| cluster > clusterIp                    | :heavy_check_mark:         | Cluster Ip                                     |
| cluster > intName                    | :heavy_check_mark:         | storage and compute intent name for creation                                    |
| witness                     | :heavy_check_mark:         | XML group of variables for witness as quorum for the cluster                                    |
| witness > resourceGroup                    | :heavy_check_mark:         | resource group name                                     |
| witness > location                    | :heavy_check_mark:         | location                                     |
| witness > storageAccName                    | :heavy_check_mark:         | storage account name                                    |

.....



```hcl
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <server1>
    <add name="server1" serverName="xxxxDELLHCINODES01" passwd="xxxxxxxxx" adapter1="SLOT 3 Port 1" c="SLOT 3 Port 2"/>
  </server1>
  <server2>
    <add name="server2" serverName="xxxxDELLHCINODES02" passwd="xxxxxxxxx" adapter1="SLOT 3 Port 1" adapter2="SLOT 3 Port 2"/>
  </server2>  
  <domain>
    <add name="domain" domainUser="abc\administrator" domainName="abc.com" domainPasswd="xxxxx"/>
  </domain>  
  <cluster>
    <add name="cluster" clusterName="dellcluster01" clusterIp="10.1.1.1" intName="Cluster_ComputeStorage" volumeName="Volume1"/>
  </cluster>
  <witness>
    <add name="witness" resourceGroup="xxx-stack_hci_common" location="eastus" storageAccName="xxxstackhciacc01"/>
  </witness>
  <azureConfig>
    <add name="azureConfig" subscriptionId="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" hciRgName="xxx-stackhci-cluster-rg"/>
  </azureConfig>
  <appSettings>
  </appSettings>
</configuration>
```


### Script: [main1.ps1](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/_main1.ps1)

- script: main1.ps1
- purpose: 

```hcl
    prepare each server before cluster creation 
    Step 1:load parameters from appConfig.xml

    For server 1:
    Step 1.2: Join the domain and add domain accounts
    Step 1.3: Install roles and features

    For server 2:
    Step 1.2: Join the domain and add domain accounts
    Step 1.3: Install roles and features
```

### Script: [main2.ps1](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/_main2.ps1)

- script: main2.ps1
- purpose: 

```hcl
    Step 1:load parameters from appConfig.xml
    Step 2: Prep for cluster setup
    Step 2.1: Prepare drives
    Step 2.2: Test cluster configuration
    Step 3: Create the cluster
    Step 4: Start cluster 
```

### Script: [main3.ps1](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/_main3.ps1)

- script: main3.ps1
- purpose: 

```hcl
    Step 0: config file loaded 
    Step 4: Configure host networking
    Step 4.1: Review physical adapters
    Step 4.2: Configure an intent
    Step 4.2: Configure an intent for server 1 
    Step 4.2: Configure an intent for server 2 
```

### Script: [main4.ps1](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/_main4.ps1)

- script: main4.ps1
- purpose: 

```hcl
    Post configuration for Stack HCI cluster 
    Step 0: config file loaded 
    Post config Step 1: Set up cluster witness
        Set up a cluster witness
        Prepare Azure account 
        Create an Azure storage account
    Post config Step 2 : Create volume
```

### Script: [main5.ps1](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/_main5.ps1)

- script: main5.ps1
- purpose: 

```hcl
    Post configuration for Stack HCI cluster 
    Step 0: config file loaded 
    Post config Step 3: Connect and manage Azure Stack HCI registration
        Install Azure Powershell first 
        Register a cluster using PowerShell
        Install the required PowerShell cmdlets on your management computer.
        Set repo as trusted 
        Register AzStackHCI
        View registration status using PowerShell
```


