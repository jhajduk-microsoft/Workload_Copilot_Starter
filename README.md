# Workload Copilot Starter

This project has most of the pieces need to deploy a Microsoft Copilot App. The focus of the app will be to help non-Azure professionals deploy their workloads into Azure without going into the portal.
The Bash script automates the management of Azure resources related to the workload copilot AI project. It includes functionalities to set up necessary Azure resources, manage deployments, and clean up resources. It handles Azure OpenAI resources, Azure AI Hub, and Azure Search services.

## Prerequisites

- Azure CLI must be installed on your machine.
- Install the ml CLI extension: az extension add -n ml
- This script will log you into your tenant and set your subscription as the target.
- Bash environment to run the script.
- Java installed locally
- Python packages:

`os`
`tika`
`requests`
`promptflow-rag`
`azure-ai-ml -U`
`openai`
`azure-identity`
`azure-search-documents==11.4.0`
`promptflow[azure]==1.11.0`
`promptflow-tracing==1.11.0`
`promptflow-tools==1.4.0`
`promptflow-evals==0.3.0`
`jinja2`
`aiohttp`
`python-dotenv`

## Part One

## 1. Infrastructure Deployment

Before running the script, ensure the `.env` file located in the parent directory is properly set up with the necessary Azure environment variables:

- `TENANT_ID`: Your Azure Tenant ID.
- `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
- `AZURE_RESOURCE_GROUP`: Name of the Azure Resource Group to manage.
- `LOCATION`: Azure region for deploying resources.
- `WORKSPACE_NAME`: Name for the Azure AI Studio Hub resource.
- `WORKSPACE_SKU_NAME`: Name of the Azure AI Hub resource.
- `WORKSPACE_PROJECT_NAME`: Name of your project.
- `AZURE_OPENAI_NAME`: Name of the Azure OpenAI resource.
- `AZURE_OPENAI_SKU_NAME`: SKU for the Azure OpenAI service.
- `AZURE_OPENAI_API_VERSION`: API version of Azure OpenAI. Set to `2024-08-06`
- `AZURE_OPENAI_CONNECTION_NAME`: The connection name for AOAI in Azure AI Studio.
- `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`: Deployment name for the embedding model. Set to `text-embedding-ada-002`
- `AZURE_OPENAI_EMBEDDING_MODEL_VERSION`: Version of the embedding model. Set to `2`
- `AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME`: Deployment name for the completion model.
- `AZURE_OPENAI_COMPLETION_VERSION_NAME`: Version of the completion model.
- `AZUREAI_SEARCH_NAME`: Name of the Azure AI Search resource
- `AZUREAI_SEARCH_SKU`: SKU for the Azure AI Search resource
- `AZUREAI_SEARCH_CONNECTION_NAME`: The connection name for Azure AI Search resource in Azure AI Studio.
- `AZUREAI_SEARCH_INDEX_NAME`: The name of the index that will be create in Azure AI Search.

## Usage

Run the script with one of the following commands depending on your needs:

```bash
bash ./infra.sh setup
bash ./infra.sh destroy
```

## 2. Create the connection to Azure AI Search and Azure OpenAI in Azure AI Studio

- Open the Azure AI Studio and check for an Azure AI Search connected resource.
- In AI Studio, go to your project.
- Launch the Studio.
- Click on **Settings** in the left hand pane.
- Click on **++ New Connection**.
- Select **Azure AI Search**.
- The Azure AI Search resource you created should pop up automatically.
- Select **Add Connection**.
- Click Close.
- Repeat these steps for the Azure OpenAI connection.
- If you **View All** of the connections in the AI Studio menu, you should see both new connections in the list.

## 3. Add the Azure OpenAI models into Azure AI Studio

- Go to your project in AI Studio.
- Select **Components > Deployments**.
- Ensure that you see the embedding and completion models as deployments on this page. These will come from completing the previous step.

## 4. Permissions

- Add yourself to the Azure OpenAI resource in the portal as **Cognitive Services OpenAI Contributor** and **Cognitive Services Contributor**
- Add yourself to the Azure AI Search resource in the portal as **Search Index Data Contributor** and **Search Service Contributor**
- Go to your Azure AI Search resource in the portal. Select **Keys**. Select **Both** to enable RBAC and Key authentication.

## 5. Generate the "customer data"

This is where you can add data for the LLM to train on. It can be deployment instructions or whatever you like the user to be able to speak about. There are rate limits so you may want to keep it targeted for this lab.

## 6. Create the Search Index

In this section, we will build the index for the data to be consumed. Use the `build_index.py` Ensure that you have the following environment variable: `AZUREAI_SEARCH_INDEX_NAME=index_name`

``` bash
python build_index.py
```

## **If you are on the S0 Azure OpenAI tier, skip step 5 and 6**

## 5. System Prompt

In the `chat.prompty` file under the `copilot_flow` folder, change the system prompt to a message that is relevant to your use case.

## 6. Query Intent

In the `queryIntent.prompty` file under the `copilot_flow` folder, change the example desired interactions system prompt to what is relevant to your use case.

## 7. Test Your Copilot

### Note: Ensure that you do not exceed the rate limits of the S0 tier Azure OpenAI instance. In order to prevent hitting the rate limits, I have removed the data form chat.prompty and queryIntent.prompty files. These files are responsible for chat history, which is not needed for this lab. Ensure that you pay attention to messages that you are exceeding the rate limit and pay attention to the backoff time.

### In the Terminal

Run `pf flow test --flow ./copilot_flow --inputs chat_input="What is a data science virtual machine?"`

### With the UI

Run `pf flow test --flow ./copilot_flow --ui`