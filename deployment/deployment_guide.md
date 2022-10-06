
### Prepare input parameters for appConfig.xml 

1. Update each parameters in XML

2. List of parameters:


### IoTHub Device Client

| Features                                                                                                         | Status                     | Description                                                                                                                                                                                                          |
|------------------------------------------------------------------------------------------------------------------|----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [Authentication](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-security-deployment)                     | :heavy_check_mark:         | Connect your device to IoT Hub securely with supported authentication, including symmetric key, X-509 Self Signed, Certificate Authority (CA) Signed, and SASToken                                     |
| [Send device-to-cloud message](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-d2c)     | :heavy_check_mark:         | Send device-to-cloud messages (max 256KB) to IoT Hub with the option to add custom properties.                                                                                                                       |
| [Receive cloud-to-device messages](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-messages-c2d) | :heavy_check_mark:         | Receive cloud-to-device messages and read associated custom and system properties from IoT Hub.                                                        |
| [Device Twins](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-device-twins)                     | :heavy_check_mark:         | IoT Hub persists a device twin for each device that you connect to IoT Hub.  The device can perform operations like get twin tags, subscribe to desired properties.                                                |
| [Direct Methods](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-direct-methods)                 | :heavy_check_mark:         | IoT Hub gives you the ability to invoke direct methods on devices from the cloud.  The SDK supports handler for method specific and generic operation.                                                            |
| [Connection Status and Error reporting](https://docs.microsoft.com/en-us/rest/api/iothub/common-error-codes)     | :heavy_check_mark:   | Error reporting for IoT Hub supported error code.                                                                                         |
| Connection Retry                                                                                                   | :heavy_check_mark:         | Dropped connections will be retried with a fixed 10 second interval by default. This functionality can be disabled if desired, and the interval can be configured   |
| [Upload file to Blob](https://docs.microsoft.com/en-us/azure/iot-hub/iot-hub-devguide-file-upload)               | :heavy_check_mark:         | A device can initiate a file upload and notifies IoT Hub when the upload is complete.  |


```hcl
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <server1>
    <add name="server1" serverName="xxxxDELLHCINODES01" passwd="xxxxxxxxx" adapter1="SLOT 3 Port 1" adapter2="SLOT 3 Port 2"/>
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