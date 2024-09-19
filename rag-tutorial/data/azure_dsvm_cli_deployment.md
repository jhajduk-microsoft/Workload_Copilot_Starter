
# Deploying Data Science VMs in Azure Using the Azure CLI

## Overview

Azure Data Science Virtual Machines (DSVMs) can be deployed quickly and efficiently using the Azure Command-Line Interface (CLI). The Azure CLI provides a flexible and powerful way to create VMs with various configurations including different SKU sizes, operating systems, and resource settings.

In this guide, we’ll walk through multiple examples of deploying DSVMs using Azure CLI.

## Prerequisites

1. Install Azure CLI from [this guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
2. Login to Azure using `az login`.
3. Make sure you have a resource group ready. If not, create one with:
   ```bash
   az group create --name MyResourceGroup --location eastus
   ```

## General Syntax for Deploying DSVMs

The basic command to deploy a DSVM using the Azure CLI is:
```bash
az vm create --resource-group <ResourceGroupName> --name <VMName> --image <ImageURN> --size <VMSize> --admin-username <AdminUser> --generate-ssh-keys
```

### Image URNs

The DSVMs are available under several different images in Azure. Below are some of the most commonly used ones:
- **Ubuntu DSVM**: `microsoft-dsvm:ubuntu-2004:2004-gen2:latest`
- **Windows 2019 DSVM**: `microsoft-dsvm:windows-2019:win2019-gen2:latest`

## Example 1: Deploying an Ubuntu DSVM (Standard_DS3_v2 SKU)

This command creates an Ubuntu-based Data Science VM using the Standard_DS3_v2 size, which is suitable for general-purpose data science workloads.

```bash
az vm create     --resource-group MyResourceGroup     --name MyUbuntuDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_DS3_v2     --admin-username azureuser     --generate-ssh-keys
```

## Example 2: Deploying a Windows DSVM (Standard_D4s_v3 SKU)

This example demonstrates how to deploy a Windows-based DSVM with the Standard_D4s_v3 SKU, which offers more CPU and memory for larger-scale experiments.

```bash
az vm create     --resource-group MyResourceGroup     --name MyWindowsDSVM     --image microsoft-dsvm:windows-2019:win2019-gen2:latest     --size Standard_D4s_v3     --admin-username azureuser     --admin-password MyComplexPassword!123
```

## Example 3: Deploying a GPU-Enabled DSVM (NC6_Promo)

If you need GPU capabilities for deep learning, you can use the `Standard_NC6_Promo` SKU, which offers an NVIDIA Tesla K80 GPU.

```bash
az vm create     --resource-group MyResourceGroup     --name MyGPUDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_NC6_Promo     --admin-username azureuser     --generate-ssh-keys
```

## Example 4: Deploying a VM with Additional Customization

You can also pass additional parameters such as networking, OS disk size, and tags. Here’s an example where we specify a different virtual network and disk size:

```bash
az vm create     --resource-group MyResourceGroup     --name CustomDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_DS3_v2     --admin-username azureuser     --generate-ssh-keys     --vnet-name MyVNet     --subnet MySubnet     --os-disk-size-gb 128     --tags project=data-science environment=production
```

## Useful Azure CLI Commands for Managing DSVMs

### List Available VM Sizes in a Region

```bash
az vm list-sizes --location eastus
```

### Start a VM

```bash
az vm start --resource-group MyResourceGroup --name MyDSVM
```

### Stop a VM

```bash
az vm stop --resource-group MyResourceGroup --name MyDSVM
```

### Delete a VM

```bash
az vm delete --resource-group MyResourceGroup --name MyDSVM --yes
```

### View the Public IP Address of a VM

```bash
az vm show --resource-group MyResourceGroup --name MyDSVM --show-details --query [publicIps] --output tsv
```

## Conclusion

Azure CLI provides a powerful toolset to quickly deploy Data Science VMs on Azure. Whether you need a basic VM for general data science tasks, or a GPU-enabled instance for deep learning workloads, the CLI allows for flexible and customizable deployments.
