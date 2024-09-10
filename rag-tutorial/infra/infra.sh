#!/bin/bash

# Export environment variables
set -a
source ../.env
set +a

# Variables (replace <subscriptionID> with your actual Azure subscription ID)
tenant=$TENANT_ID
subscriptionID=$AZURE_SUBSCRIPTION_ID
resourceGroupName=$AZURE_RESOURCE_GROUP
aiHubName=$WORKSPACE_NAME
aoaiName=$AZURE_OPENAI_NAME
location=$LOCATION
projectName=$WORKSPACE_PROJECT_NAME
openaiSkuName=$AZURE_OPENAI_SKU_NAME
embeddingName=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT
embeddingModelVersion=$AZURE_OPENAI_EMBEDDING_MODEL_VERSION
completionName=$AZURE_OPENAI_DEPLOYMENT_NAME
completionModelVersion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
searchName=$AZUREAI_SEARCH_NAME
searchServiceSku=$AZUREAI_SEARCH_SKU
storageAccountName=$STORAGE_ACCOUNT_NAME
storageAccountSku=$STORAGE_ACCOUNT_SKU
storageContainerName=$STORAGE_CONTAINER_NAME
dataDirectory='../data/'

# Sign in to Azure CLI
az config set core.login_experience_v2=off
az login --tenant $tenant || { echo "Failed to log in to Azure"; exit 1; }
az account set --subscription $subscriptionID

if [ "$1" == "setup" ]; then

    # Set up resources
    echo "Setting up resources..."

    # Check if resource group exists
    if az group show --name $resourceGroupName &>/dev/null; then
        echo "Resource group $resourceGroupName already exists"
    else
        # Create a resource group
        echo "Creating Resource Group"
        if ! az group create --name $resourceGroupName --location $location; then
            echo "Failed to create resource group"
            exit 1
        fi
    fi

    # Check if Azure AI Hub resource exists
    if az ml workspace show --name $aiHubName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure AI Hub resource $aiHubName already exists"
    else
        # Create Azure AI Hub resource
        echo "Creating AI Hub"
        if ! az ml workspace create \
            --resource-group $resourceGroupName \
            --name $aiHubName \
            --kind hub; then
            echo "Failed to create Azure AI Hub resource"
            exit 1
        fi
    fi

    # Check if project resource exists
    if az ml project show --name $projectName --workspace-name $aiHubName --resource-group $resourceGroupName &>/dev/null; then
        echo "Project resource $projectName already exists"
    else
        hubID=$(az resource show --name $aiHubName --resource-group $resourceGroupName --resource-type Microsoft.MachineLearningServices/workspaces --query id --output tsv)
        # Create project resource
        echo "Creating Azure AI Project"
        if ! az ml workspace create \
            --kind project \
            --hub-id $hubID\
            --resource-group $resourceGroupName \
            --name $projectName; then          
        echo "Failed to create project resource"
        exit 1
        fi
    fi

    # Check if Azure AI Search resource exists
    if az search service show --name $searchName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure AI Search resource $searchName already exists"
    else
        # Create Azure AI Search resource
        echo "Creating Search Service"
        if ! az search service create \
            --name $searchName \
            --resource-group $resourceGroupName \
            --location $location \
            --sku $searchServiceSku \
            --subscription $subscriptionID; then
            echo "Failed to create Azure AI Search resource"
            exit 1
        fi
    fi

    # Check if Azure OpenAI resource exists
    if az cognitiveservices account show --name $aoaiName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure OpenAI resource $aoaiName already exists"
    else
        # Create Azure OpenAI resource
        echo "Creating OpenAI"
        if ! az cognitiveservices account create \
            --name $aoaiName \
            --resource-group $resourceGroupName \
            --kind "OpenAI" \
            --sku $openaiSkuName \
            --location $location \
            --custom-domain $aoaiName \
            --yes; then
            echo "Failed to create Azure OpenAI resource"
            exit 1
        fi
    fi

    # Check if ada deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $embeddingName &>/dev/null; then
        echo "Ada deployment already exists"
    else
        echo "Creating Ada deployment"
        # Create ada deployment
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $embeddingName \
            --model-format OpenAI \
            --model-name $embeddingName \
            --model-version $embeddingModelVersion; then
            echo "Failed to create ada deployment"
            exit 1
        fi
    fi

    # Check if gpt-3.5-turbo deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $completionName &>/dev/null; then
        echo "GPT-3.5-turbo deployment already exists"
    else
        # Create gpt-3.5-turbo deployment
        echo "Creating GPT deployment"
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $completionName \
            --model-format OpenAI \
            --model-name $completionName \
            --model-version $completionModelVersion; then
            echo "Failed to create GPT-3.5-turbo deployment"
            exit 1
        fi
    fi

    # Check if storage account exists
    if az storage account show --name $storageAccountName --resource-group $resourceGroupName &>/dev/null; then
        echo "Storage account $storageAccountName already exists"
    else
        # Create storage account
        echo "Creating Storage Account"
        if ! az storage account create \
            --name $storageAccountName \
            --resource-group $resourceGroupName \
            --location $location \
            --sku $storageAccountSku \
            --kind StorageV2 \
            --https-only true \
            --allow-blob-public-access false; then
            echo "Failed to create storage account"
            exit 1
        fi
    fi

    # Check if container exists
    if az storage container exists \
        --name $storageContainerName --resource-group &>/dev/null; then \
        echo "Container $storageContainerName already exists"
    else
        # Create container
        echo "Creating Container"
        if ! az storage container create \
            --name $storageContainerName \
            --account-name $storageAccountName \
            --account-key $(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv); then
            echo "Failed to create container"
            exit 1
        fi
    fi

    # Upload data to storage account if files do not exist
    echo "Uploading Data to Storage Account"
    if ! az storage blob list \
        --container-name $storageContainerName \
        --account-name $storageAccountName \
        --account-key $(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv) \
        --query "[?contains(name, '.txt')].name" -o tsv | grep -q -v "data/"; then
        if ! az storage blob upload-batch \
            --destination $storageContainerName \
            --account-name $storageAccountName \
            --account-key $(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv) \
            --source $dataDirectory; then
            echo "Failed to upload data to storage account"
            exit 1
        fi
    else
        echo "Files already exist in storage account"
    fi

    # Retrieve the REST API endpoint URL if it does not already exist
    if ! grep -q "AZURE_OPENAI_ENDPOINT=" ../.env; then
    AOAIendpoint=$(az cognitiveservices account show --name $aoaiName --resource-group $resourceGroupName --query "properties.endpoint" -o tsv)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve AOAI endpoint URL"
            exit 1
    fi
    echo >> ../.env
    echo "AZURE_OPENAI_ENDPOINT=$AOAIendpoint" >> ../.env
    fi

    # Retrieve the primary API key if it does not already exist
    if ! grep -q "AZURE_OPENAI_API_KEY=" ../.env; then
    AOAIApiKey=$(az cognitiveservices account keys list --name $aoaiName --resource-group $resourceGroupName --query "key1" -o tsv)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve AOAI API key"
            exit 1
    fi

    echo "AZURE_OPENAI_API_KEY=$AOAIApiKey" >> ../.env
    fi

    if ! grep -q "AZUREAI_SEARCH_ENDPOINT=" ../.env; then
    searchEndpoint=$(az search service show --name $searchName --resource-group $resourceGroupName --query "properties.url" -o tsv)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve Azure AI Search endpoint"
            exit 1
        fi
    echo "AZUREAI_SEARCH_ENDPOINT=https://$searchName.search.windows.net" >> ../.env
    fi

    # Retrieve the admin key for Azure AI Search if it does not already exist
    if ! grep -q "AZUREAI_SEARCH_ADMIN_KEY=" ../.env; then
    searchAdminKey=$(az search admin-key show --service-name $searchName --resource-group $resourceGroupName --query "primaryKey" -o tsv)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve Azure AI Search Admin Key"
            exit 1
        fi
    echo "AZUREAI_SEARCH_ADMIN_KEY=$searchAdminKey" >> ../.env
    fi
    
        # Retrieve the admin key for Azure AI Search if it does not already exist
    if ! grep -q "STORAGE_ACCOUNT_KEY=" ../.env; then
    strAccountKey=$(az storage account keys list --account-name $storageAccountName --resource-group $resourceGroupName --query "[0].value" -o tsv)
        if [ $? -ne 0 ]; then
            echo "Failed to retrieve Azure Storage Account Key"
            exit 1
        fi
    echo "STORAGE_ACCOUNT_KEY=$strAccountKey" >> ../.env
    fi

    echo "Resources created successfully"

fi


# Check if the flag is set to destroy resources
if [ "$1" == "destroy" ]; then
    # Destroy resources
    echo "Destroying resources..."

    # Delete resource group
    if az group show --name $resourceGroupName &>/dev/null; then
        az group delete \
            --name $resourceGroupName

        echo "Resource group $resourceGroupName deleted"
    else
        echo "Resource group $resourceGroupName does not exist"
    fi
    
    echo "Resources destroyed successfully"
    exit 0
fi