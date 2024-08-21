#!/bin/bash

# Export environment variables
set -a
source ../.env
set +a

# Variables (replace <subscriptionID> with your actual Azure subscription ID)
tenant=$TENANTID
subscriptionID=$SUBSCRIPTIONID
resourceGroupName=$RESOURCEGROUP
resourceName=$AOAINAME
location=$LOCATION
hubName=$HUBNAME
projectName=$PROJECT_NAME
openaiSkuName=$AZURE_OPENAI_SKU_NAME
openaiKind=$AZURE_OPENAI_KIND
embeddingName=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT
embeddingModelVersion=$AZURE_OPENAI_EMBEDDING_MODEL_VERSION
completionName=$AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME
completionModelVersion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
searchName=$AZURE_AI_SEARCH_NAME
searchServiceSku=$SEARCH_SERVICE_SKU
storageAccountName=$STORAGE_ACCOUNT_NAME
storageAccountSku=$STORAGE_ACCOUNT_SKU
storageAccountKind=$STORAGE_ACCOUNT_KIND

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
        echo "Creating Resoruce Group"
        if ! az group create --name $resourceGroupName --location $location; then
            echo "Failed to create resource group"
            exit 1
        fi
    fi

    # Check if Azure AI Hub resource exists
    if az ml workspace show --name $hubName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure AI Hub resource $hubName already exists"
    else
        # Create Azure AI Hub resource
        echo "Creating AI Hub"
        if ! az ml workspace create \
            --resource-group $resourceGroupName \
            --name $hubName \
            --kind hub; then
            echo "Failed to create Azure AI Hub resource"
            exit 1
        fi
    fi

    # Check if project resource exists
    if az ml project show --name $projectName --workspace-name $hubName --resource-group $resourceGroupName &>/dev/null; then
        echo "Project resource $projectName already exists"
    else
        hubID=$(az resource show --name $hubName --resource-group $resourceGroupName --resource-type Microsoft.MachineLearningServices/workspaces --query id --output tsv)
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
    if az cognitiveservices account show --name $resourceName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure OpenAI resource $resourceName already exists"
    else
        # Create Azure OpenAI resource
        echo "Creating OpenAI"
        if ! az cognitiveservices account create \
            --name $resourceName \
            --resource-group $resourceGroupName \
            --kind "OpenAI" \
            --sku $openaiSkuName \
            --location $location \
            --yes; then
            echo "Failed to create Azure OpenAI resource"
            exit 1
        fi
    fi

    # Check if ada deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $resourceName \
        --deployment-name $embeddingName &>/dev/null; then
        echo "Ada deployment already exists"
    else
        echo "Creating Ada deployment"
        # Create ada deployment
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $resourceName \
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
        --name $resourceName \
        --deployment-name $completionName &>/dev/null; then
        echo "GPT-3.5-turbo deployment already exists"
    else
        # Create gpt-3.5-turbo deployment
        echo "Creating GPT deployment"
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $resourceName \
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
        echo "Creating storage account"
        if ! az storage account create \
            --name "$storageAccountName$(date +%s)" \
            --resource-group $resourceGroupName \
            --location $location \
            --sku $storageAccountSku \
            --kind $storageAccountKind \
            --https-only true \
            --default-action Deny; then
            echo "Failed to create storage account"
            exit 1
        fi
    fi
fi

# Check if the flag is set to destroy resources
if [ "$1" == "destroy" ]; then
    # Destroy resources
    echo "Destroying resources..."

    # Delete project resource
    if az ml project show --name $projectName --workspace-name $hubName --resource-group $resourceGroupName &>/dev/null; then
        az ml project delete \
            --name $projectName \
            --workspace-name $hubName \
            --resource-group $resourceGroupName

        echo "Project resource $projectName deleted"
    else
        echo "Project resource $projectName does not exist"
    fi

    # Delete Azure AI Search deployment
    if az search service deployment show \
        --resource-group $resourceGroupName \
        --service-name $searchName \
        --name $deploymentName &>/dev/null; then
        az search service deployment delete \
            --resource-group $resourceGroupName \
            --service-name $searchName \
            --name $deploymentName

        echo "Azure AI Search deployment deleted"
    else
        echo "Azure AI Search deployment does not exist"
    fi

    # Delete completion model deployment
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $resourceName \
        --deployment-name $completionName &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $resourceName \
            --deployment-name $completionName

        echo "Completion model deployment deleted"
    else
        echo "Completion model deployment does not exist"
    fi
    
    # Delete embedding model deployment
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $resourceName \
        --deployment-name $embeddingName &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $resourceName \
            --deployment-name $embeddingName

        echo "Embedding model deployment deleted"
    else
        echo "Embedding model deployment does not exist"
    fi
    
    # Delete Azure OpenAI resource
    if az cognitiveservices account show --name $resourceName --resource-group $resourceGroupName &>/dev/null; then
        az cognitiveservices account delete \
            --name $resourceName \
            --resource-group $resourceGroupName

        echo "OpenAI resource $resourceName deleted"
    else
        echo "OpenAI resource $resourceName does not exist"
    fi
    
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

# Retrieve the REST API endpoint URL if it does not already exist
if ! grep -q "AZURE_OPENAI_ENDPOINT=" ../.env; then
    AOAIendpoint=$(az cognitiveservices account show --name $resourceName --resource-group $resourceGroupName --query "properties.endpoint" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve AOAI endpoint URL"
        exit 1
    fi
    echo >> ../.env
    echo "AZURE_OPENAI_ENDPOINT=$AOAIendpoint" >> ../.env
fi

# Retrieve the primary API key if it does not already exist
if ! grep -q "AOAI_API_KEY=" ../.env; then
    AOAIApiKey=$(az cognitiveservices account keys list --name $resourceName --resource-group $resourceGroupName --query "key1" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve AOAI API key"
        exit 1
    fi
    echo "AOAI_API_KEY=$AOAIApiKey" >> ../.env
fi

# Retrieve the endpoint for Azure AI Search if it does not already exist
if ! grep -q "AZURE_SEARCH_ENDPOINT=" ../.env; then
    searchEndpoint=$(az search service show --name $searchName --resource-group $resourceGroupName --query "properties.url" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Azure AI Search endpoint"
        exit 1
    fi
    echo "AZURE_SEARCH_ENDPOINT=https://$searchName.search.windows.net" >> ../.env
fi

# Retrieve the admin key for Azure AI Search if it does not already exist
if ! grep -q "SEARCH_ADMIN_KEY=" ../.env; then
    searchAdminKey=$(az search admin-key show --service-name $searchName --resource-group $resourceGroupName --query "primaryKey" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Azure AI Search Admin Key"
        exit 1
    fi
    echo "SEARCH_ADMIN_KEY=$searchAdminKey" >> ../.env
fi

if ! grep -q "STORAGE_ACCOUNT_KEY=" ../.env; then
    storageAccountName=$(az storage account list --resource-group $resourceGroupName --query "[?contains(name, '$storageAccountName')].[name]" --output tsv)
    storageAccountKey=$(az storage account keys list --account-name "$storageAccountName" --resource-group $resourceGroupName --query '[0].value' -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve storage account key"
        exit 1
    fi
    echo "STORAGE_ACCOUNT_KEY=$storageAccountKey" >> ../.env
fi


echo "Script completed successfully"
