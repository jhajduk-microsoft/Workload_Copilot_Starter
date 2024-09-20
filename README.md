# Workload Copilot Starter

This project contains the necessary infrastructure deployment, index deployment, and promptflow files needed to deploy a Microsoft Copilot solution. In this repo, you will find an Azure CLI script that will deploy the necessary infrastructure in the Azure Portal. It is located in `rag-tutorial\infra\infra.sh` It is a shell script so you will need a shell terminal to run this script. The following setup and infrastructure deployment can be deployed using a VSCode terminal window.

## Set up a shell terminal in VSCode

If using windows, use [Git Bash](https://git-scm.com/downloads). Then, open VSCode, type CTRL+Shift+P, type in `Select Default Profile` and choose Git Bash. Open a terminal window in VSCode and ensure that Git Bash is selected. In VSCode On Mac, use the `zsh` shell in a terminal window.

## Prerequisites

- A cloned (forked, then cloned, if you desire) copy of this repository on your local machine
- An Azure subscription where the resources will be deployed. You can set up an Azure Free Account [here](https://azure.microsoft.com/pricing/purchase-options/azure-account?msockid=2ebef0a87030677c109ee28e7198663b) - Use the `Azure free account` option. You will need to use a credit card for a temporary $1 charge that will be reversed. After you are done with the account, you may cancel using the instructions [here](https://learn.microsoft.com/azure/cost-management-billing/manage/cancel-azure-subscription) **Be mindful of your spend in free accounts!** The `infra.sh` script can help set up and tear down infrastructure quickly and avoid unintended expenses.
- [Visual Studio Code](https://code.visualstudio.com/Download)
- Azure CLI must be installed on your machine. Ensure you have the latest version.
- Install the `ml` extension to the Azure CLI: `az extension add -n ml`
- Python packages. There is a requirements.txt file in the location rag-tutorial/copilot_flow/requirements.txt Navigate to the rag-tutorial folder and run `pip install -r .\copilot_flow\requirements.txt` (You may have to use forward slashes depending on your OS type)

## 1. Infrastructure Deployment

Create the `.env` file in the rag-tutorial directory and populate these variables:

- `TENANT_ID`: Your Azure Tenant ID.
- `AZURE_SUBSCRIPTION_ID`: Your Azure Subscription ID.
- `AZURE_RESOURCE_GROUP`: Desired name of the Azure Resource Group to manage.
- `LOCATION`: Desired Azure region for deploying resources.
- `WORKSPACE_NAME`: Desired name for the Azure AI Studio Hub resource.
- `WORKSPACE_PROJECT_NAME`: Desired name of your project.
- `AZURE_OPENAI_NAME`: Desired name of the Azure OpenAI resource.
- `AZURE_OPENAI_SKU_NAME`: Desired SKU for the Azure OpenAI service.
- `AZURE_OPENAI_API_VERSION`: API version of Azure OpenAI. [Check the Azure OpenAI API versions](https://learn.microsoft.com/azure/ai-services/openai/reference)
- `AZURE_OPENAI_CONNECTION_NAME`: The connection name for AOAI in Azure AI Studio.
- `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`: Deployment name for the embedding model.
- `AZURE_OPENAI_EMBEDDING_MODEL_VERSION`: Version of the embedding model.
- `AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME`: Deployment name for the completion model. e.g. gpt-35-turbo
- `AZURE_OPENAI_COMPLETION_VERSION_NAME`: Version of the completion model.
- `AZUREAI_SEARCH_NAME`: Desired name of the Azure AI Search resource
- `AZUREAI_SEARCH_SKU`: Desired SKU for the Azure AI Search resource
- `AZUREAI_SEARCH_CONNECTION_NAME`: Desired connection name for Azure AI Search resource in Azure AI Studio.
- `AZUREAI_SEARCH_INDEX_NAME`: Desired name of the index that will be create in Azure AI Search.

## Usage

Run the script with one of the following commands depending on your needs:

```bash
bash ./infra.sh setup
bash ./infra.sh destroy
```

After you run this script, the endpoints and keys for Azure OpenAI and Azure AI Search will be added to the `.env` file. View them.

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

- Go to the Azure portal
- Go to the resource group that you created
- Click on the resource with Type Azure AI Hub
- Click on **Launch Azure AI Studio**
- Select **Deployments** in the left hand menu
- Select **Deploy model** > **Deploy base model**
- From the left hand list, select either there embedding model or the GPT model that you deployed with the infra script
- The next window that pops up should display the deployment details for the AOAI instance and mode that you deployed
- Select **Connect and deploy**
- Ensure that you see the embedding and GPT models as deployments on this page. These will come from completing the previous step.

## 4. Permissions

- Add yourself to the Azure OpenAI resource in the portal as **Cognitive Services OpenAI Contributor** and **Cognitive Services Contributor**
- Add yourself to the Azure AI Search resource in the portal as **Search Index Data Contributor** and **Search Service Contributor**
- Go to your Azure AI Search resource in the portal. Select **Keys**. Select **Both** to enable RBAC and Key authentication.

## 5. Generate the "customer data"

This is where you can add data for the LLM to train on. It can be deployment instructions or whatever you like the user to be able to ask about.

## 6. Create the Search Index

In this section, we will build the search index for the data to be consumed. Use the `build_index.py` Ensure that you have the following environment variable: `AZUREAI_SEARCH_INDEX_NAME=index_name`

``` bash
python build_index.py
```

## **If you are on the S0 Azure OpenAI tier, skip step 7 and 8**

## 7. System Prompt

In the `chat.prompty` file under the `copilot_flow` folder, change the system prompt to a message that is relevant to your use case.

## 8. Query Intent

In the `queryIntent.prompty` file under the `copilot_flow` folder, change the example desired interactions system prompt to what is relevant to your use case.

## 9. Test Your Copilot

### Note: Ensure that you do not exceed the rate limits of the S0 tier Azure OpenAI instance. In order to prevent hitting the rate limits, I have removed the data form chat.prompty and queryIntent.prompty files. These files are responsible for chat history, which is not needed for this lab. Ensure that you pay attention to messages that you are exceeding the rate limit and pay attention to the backoff time.

### In the Terminal

Run `pf flow test --flow ./copilot_flow --inputs chat_input="What is a data science virtual machine?"`

### With the UI

Run `pf flow test --flow ./copilot_flow --ui`

## Known Issues

- In Azure AI Studio, you may encounter a permissions error when viewing deployed models to the workspace. Log out of Azure AI Studio and the portal and log in again to clear this error.

- Rate limit exceeded when running promptflow queries. This can happen if the number of requests have exceeded the threshold that the Azure OPenAI service accepts. Either wait for a few minutes and try again or redeploy the infrastructure. You may have to choose a new region. This is only noted in a small number of cases.

- If you get the error that the `Principal does not have access to API/Version` when running the promptflow query, assign yourself the `Cognitive Services OpenAI Contributor` role on the Azure OpenAI resource. If your Azure OpenAI resource is obscured in the Azure AI Studio as an AI Services resource, grant yourself this role on the resource group.