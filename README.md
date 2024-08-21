# Azure Resources Management Script

This Bash script automates the management of Azure resources related to the workload copilot AI project. It includes functionalities to set up necessary Azure resources, manage deployments, and clean up resources. It handles Azure OpenAI resources, Azure AI Hub, and Azure Search services.

## Prerequisites

- Azure CLI must be installed on your machine.
- Install the ml CLI extension: az extension add -n ml
- This script will log you into your tenant and set your subscription as the target.
- Bash environment to run the script.

## 1. Infrastructure Deployment

Before running the script, ensure the `.env` file located in the parent directory is properly set up with the necessary Azure environment variables:

- `TENANTID`: Your Azure Tenant ID.
- `SUBSCRIPTIONID`: Your Azure Subscription ID.
- `RESOURCEGROUP`: Name of the Azure Resource Group to manage.
- `AOAINAME`: Name for the Azure OpenAI resource.
- `LOCATION`: Azure region for deploying resources.
- `HUBNAME`: Name of the Azure AI Hub resource.
- `PROJECT_NAME`: Name of your project.
- `AZURE_OPENAI_SKU_NAME`: SKU for the Azure OpenAI service.
- `AZURE_OPENAI_KIND`: Type of Azure OpenAI resource.
- `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`: Deployment name for the embedding model.
- `AZURE_OPENAI_EMBEDDING_MODEL_VERSION`: Version of the embedding model.
- `AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME`: Deployment name for the completion model.
- `AZURE_OPENAI_COMPLETION_VERSION_NAME`: Version of the completion model.
- `AZURE_AI_SEARCH_NAME`: Name of the Azure Search Service.
- `SEARCH_SERVICE_SKU`: SKU for the Azure Search Service.

## Usage

Run the script with one of the following commands depending on your need:

```bash
./infra.sh setup
./infra.sh destroy
```

## 2. Create the connection to Azure AI Search

- Open the Azure AI Studio and check for an Azure AI Search connected resource.
- In AI Studio, go to your project.
- Launch the Studio.
- Click on **Settings** in the left hand pane
- Click on **++ New Connection**
- Select **Azure AI Search**
- The Azure AI Search resource you created should pop up automatically.
- Select **Add Connection**
- Click Close
- If you **View All** of the connections in the AI Studio menu, you should see the new Azure AI Search Connection

## 3. Generate the "customer data"

The point of this tutorial is to use data from the customer. We will not be using actual customer data, but instead we will generate the data. Prompt for chatGPT:

## 4. Create the Search Index

In this section, we will build the index for the data to be consumed. Use the `build_index.py` script and set the `index_name` variable. Once you have chosen a name, set another environment variable in the .env file: `AZUREAI_SEARCH_INDEX_NAME=index_name`

### Requirements

``` bash
pip install requests beautifulsoup4
pip install os
pip install requests
pip install promptflow-rag
pip install azure-ai-ml -U
```

Once you have the prerequisites, you can run the following:

``` bash
python build_index.py
```

## 5. Develop Customer RAG Code
