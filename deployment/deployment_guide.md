
### script: main1.ps1

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

### script: main2.ps1

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

### script: main3.ps1

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

### script: main4.ps1

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

### script: main5.ps1 

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