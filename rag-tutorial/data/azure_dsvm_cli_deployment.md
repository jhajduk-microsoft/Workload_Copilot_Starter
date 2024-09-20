
# Data Science VMs in Azure

## Overview

Azure Data Science Virtual Machines (DSVM) are specially configured virtual machines on the Azure cloud that come pre-installed with a wide range of popular data science tools, libraries, and frameworks. They are designed to simplify the process of data analysis, machine learning, and deep learning projects by providing a robust, out-of-the-box environment for data scientists, machine learning engineers, and AI researchers.

## Key Capabilities

### 1. Pre-Configured Environment

Azure DSVMs come pre-installed with popular data science tools such as:

- Python, R, and Julia programming languages
- Data science libraries like TensorFlow, PyTorch, scikit-learn, and XGBoost
- Jupyter, JupyterLab, and RStudio for interactive development
- Popular deep learning tools such as CUDA, cuDNN, and Intel MKL

### 2. Broad Range of Use Cases

Data Science VMs can be used for a variety of tasks including:

- Data preparation and cleaning
- Statistical analysis and hypothesis testing
- Training and evaluating machine learning models
- Deep learning experiments
- Large-scale data processing using Spark or Hadoop

# Deploying Data Science VMs in Azure Using the Azure CLI

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

## Example 1: Deploying an Ubuntu DSVM (Standard_DS3_v2 SKU)

This command creates an Ubuntu-based Data Science VM using the Standard_DS3_v2 size, which is suitable for general-purpose data science workloads.

```bash
az vm create --resource-group MyResourceGroup --name MyUbuntuDSVM --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest --size Standard_DS3_v2 --admin-username azureuser --generate-ssh-keys
```

## Example 3: Deploying a GPU-Enabled DSVM (NC6_Promo)

If you need GPU capabilities for deep learning, you can use the `Standard_NC6_Promo` SKU, which offers an NVIDIA Tesla K80 GPU.

```bash
az vm create --resource-group MyResourceGroup --name MyGPUDSVM --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest --size Standard_NC6_Promo --admin-username azureuser --generate-ssh-keys
```

## Conclusion

Azure CLI provides a powerful toolset to quickly deploy Data Science VMs on Azure. Whether you need a basic VM for general data science tasks, or a GPU-enabled instance for deep learning workloads, the CLI allows for flexible and customizable deployments.
