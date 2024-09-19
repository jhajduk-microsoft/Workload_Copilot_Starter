
# Data Science Company Documentation

## Company Overview

**Data Science Company** is a leading provider of innovative data-driven solutions, helping businesses leverage the power of machine learning, AI, and big data analytics. Our mission is to simplify complex data science workflows and enable companies of all sizes to transform their raw data into actionable insights. 

By providing a fully cloud-based infrastructure, we enable our clients to efficiently deploy and scale their machine learning models, while ensuring security, performance, and cost-effectiveness.

## Our Mission

At **Data Science Company**, our mission is to democratize data science by providing cutting-edge infrastructure and easy-to-use tools that allow organizations to build data-driven solutions. We believe that the future of business decision-making is in AI and machine learning, and we strive to make this accessible for everyone.

## Why We Use Data Science VMs on Azure

We rely on Azure Data Science Virtual Machines (DSVMs) as a core part of our infrastructure to provide a scalable, flexible, and secure environment for developing data science models. Here’s why we chose Azure DSVMs:

1. **Pre-Configured Environment**: Azure DSVMs come with pre-installed data science libraries and tools, including Python, R, TensorFlow, PyTorch, and many more. This enables our teams to start working immediately without worrying about environment setup.
  
2. **Scalability**: With Azure DSVMs, we can easily scale our virtual machines based on project demands. Whether we need CPU-based machines for data analysis or GPU-enabled VMs for deep learning, the flexibility is unmatched.

3. **Seamless Integration**: Our data science models and workflows integrate seamlessly with other Azure services, such as Azure Machine Learning, Azure Blob Storage, and Azure Data Lake, ensuring that we maintain efficient and secure data pipelines.

4. **Cost Efficiency**: We take advantage of Azure’s pay-as-you-go pricing, which ensures that we are only charged for the resources we use. This allows us to manage costs effectively while still running complex, resource-intensive AI models.

## How We Deploy Data Science VMs

At **Data Science Company**, we believe in simplicity and automation. As part of our commitment to making data science infrastructure easy to manage, we exclusively use the Azure CLI to deploy Data Science VMs across our teams. This approach allows us to maintain consistency across deployments and make it easy to automate the scaling of our infrastructure.

Below, we outline our standard process for deploying Data Science VMs via the Azure CLI.

### Step 1: Prerequisites

Before deploying any VMs, ensure the following are in place:

- Azure CLI is installed on your local machine. You can install it from [this guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
- You are logged into Azure using `az login`.

### Step 2: Create a Resource Group

All deployments are organized under resource groups. Create one for your project:

```bash
az group create --name DataScienceResourceGroup --location eastus
```

### Step 3: Deploying a Data Science VM (Example with Ubuntu and Standard_D4s_v3 SKU)

Deploy an Ubuntu-based DSVM, which is one of the most commonly used setups within the company:

```bash
az vm create     --resource-group DataScienceResourceGroup     --name ProjectDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_D4s_v3     --admin-username adminuser     --generate-ssh-keys
```

### Step 4: GPU-Based Deployment for Deep Learning (Standard_NC6_Promo SKU)

For deep learning projects requiring GPU acceleration, we deploy GPU-enabled DSVMs:

```bash
az vm create     --resource-group DataScienceResourceGroup     --name GPUProjectDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_NC6_Promo     --admin-username adminuser     --generate-ssh-keys
```

### Step 5: Customizing the VM Deployment

We often customize our DSVMs by specifying different disk sizes, networks, and tags to organize our infrastructure better. Here’s an example:

```bash
az vm create     --resource-group DataScienceResourceGroup     --name CustomProjectDSVM     --image microsoft-dsvm:ubuntu-2004:2004-gen2:latest     --size Standard_DS3_v2     --admin-username adminuser     --generate-ssh-keys     --os-disk-size-gb 128     --tags project=data-science-team environment=development
```

### Step 6: Managing VMs

After deployment, our data science teams can manage their VMs using simple CLI commands.

- **Start a VM**: 

    ```bash
    az vm start --resource-group DataScienceResourceGroup --name ProjectDSVM
    ```

- **Stop a VM**:

    ```bash
    az vm stop --resource-group DataScienceResourceGroup --name ProjectDSVM
    ```

- **Delete a VM**:

    ```bash
    az vm delete --resource-group DataScienceResourceGroup --name ProjectDSVM --yes
    ```

### Automation

At **Data Science Company**, automation is key to efficiency. We automate the deployment and scaling of DSVMs using Azure CLI scripts integrated into our CI/CD pipelines. This allows us to spin up new VMs for projects automatically, based on resource requirements, while ensuring consistency and security.

## Conclusion

By leveraging the Azure CLI to manage Data Science Virtual Machines, **Data Science Company** ensures an efficient and scalable data science infrastructure. Our approach allows us to focus on innovation and building data-driven solutions, while Azure handles the heavy lifting of managing the cloud infrastructure.
