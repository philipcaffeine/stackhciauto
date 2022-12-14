# Repo of automation job for Azure Stack HCI

A quickstart guide to deploy Azure Stack HCI via Power Shell and other tools to archieve certain extent of automation of infrastructure management. 
Also, to be able to integrate with other IaC tools, like Terraform. 

** You will be responsible for any and all infrastructure costs incurred by these resources. As a result, this repository minimizes costs by standing up the minimum required resources for a given provider

### PS automation for Azure Stack HCI cluster creation and post-configuration

For deployment details, please refer to below deployment guides, [Guide](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/deployment_guide.md).

```hcl
https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/deployment_guide.md
```

Before you start, please read pre-requisite guide for environment preparation, [Pre-requisite](https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/pre-requisite.md).

```hcl
https://github.com/philipcaffeine/stackhciauto/blob/main/deployment/pre-requisite.md
```

#### Folder structure 

[deployment]

1. *.ps1, automation scripts during Stack HCI deployment phase
2. *.xml, input parameters while loading parametes for customization 
3. *.json, new role definition file while register Stack HCI cluser to Azure Portal

### Terraform integration from main flow to invoke PS scripts 

#### Folder structure 
[terraform]
1. A simple mail.tf to simulate calling these PS scrrits from TF main flow as TF null resource 



