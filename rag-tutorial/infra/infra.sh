#!/bin/bash

# Export environment variables
set -a
source ../.env
set +a

# Variables (replace <subscriptionID> with your actual Azure subscription ID)
tenant=$TENANT_ID
subscriptionID=$AZURE_SUBSCRIPTION_ID
resourceGroupName=$AZURE_RESOURCE_GROUP + "$(datetime +%s)"
aiHubName=$WORKSPACE_NAME + "$(datetime +%s)"
aoaiName=$AZURE_OPENAI_NAME + "$(datetime +%s)"
location=$LOCATION
projectName=$WORKSPACE_PROJECT_NAME + "$(datetime +%s)"
openaiSkuName=$AZURE_OPENAI_SKU_NAME
embeddingName=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT
embeddingModelVersion=$AZURE_OPENAI_EMBEDDING_MODEL_VERSION
completionName=$AZURE_OPENAI_COMPLETION_NAME
completionModelVersion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
searchName=$AZUREAI_SEARCH_NAME + "$(datetime +%s)"
searchServiceSku=$AZUREAI_SEARCH_SKU
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
        echo "$resourceGroupName already exists"
    else
        # Create a resource group
        echo "Creating Resource Group"
        if ! az group create --name $resourceGroupName --location $location; then
            echo "Failed to create $resourceGroupName"
            exit 1
        fi
    fi

    # Check if Azure AI Hub resource exists
    if az ml workspace show \
        --name $aiHubName \
        --resource-group $resourceGroupName &>/dev/null; then
        echo "$aiHubName already exists"
    else
        # Create Azure AI Hub resource
        echo "Creating $aiHubName"
        if ! az ml workspace create \
            --resource-group $resourceGroupName \
            --name $aiHubName \
            --kind hub; then
            echo "Failed to create $aiHubName"
            exit 1
        fi
    fi

    # Check if project resource exists
    if az ml project show \
        --name $projectName \
        --workspace-name $aiHubName \
        --resource-group $resourceGroupName &>/dev/null; then
        echo "$projectName already exists"
    else
        hubID=$(az resource show --name $aiHubName --resource-group $resourceGroupName --resource-type Microsoft.MachineLearningServices/workspaces --query id --output tsv)
        # Create project resource
        echo "Creating $projectName"
        if ! az ml workspace create \
            --kind project \
            --hub-id $hubID\
            --resource-group $resourceGroupName \
            --name $projectName; then          
        echo "Failed to create $projectName"
        exit 1
        fi
    fi

    # Check if Azure AI Search resource exists
    if az search service show \
         --name $searchName \
         --resource-group $resourceGroupName &>/dev/null; then
        echo "$searchName already exists"
    else
        # Create Azure AI Search resource
        echo "Creating Search Service"
        if ! az search service create \
            --name $searchName \
            --resource-group $resourceGroupName \
            --location $location \
            --sku $searchServiceSku \
            --subscription $subscriptionID; then
            echo "Failed to create $searchName"
            exit 1
        fi
    fi

    # Check if Azure OpenAI resource exists
    if az cognitiveservices account show \
        --name $aoaiName \
        --resource-group \
        $resourceGroupName &>/dev/null; then
        echo "$aoaiName already exists"
    else
        # Create Azure OpenAI resource
        echo "Creating $aoaiName"
        if ! az cognitiveservices account create \
            --name $aoaiName \
            --resource-group $resourceGroupName \
            --kind "OpenAI" \
            --sku $openaiSkuName \
            --location $location \
            --custom-domain $aoaiName \
            --yes; then
            echo "Failed to create $aoaiName"
            exit 1
        fi
    fi

    # Check if embedding deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $embeddingName &>/dev/null; then
        echo "$embeddingName already exists"
    else
        echo "Creating $embeddingName deployment"
        # Create embedding deployment
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $embeddingName \
            --model-format OpenAI \
            --model-name $embeddingName \
            --model-version $embeddingModelVersion; then
            echo "Failed to create $embeddingName"
            exit 1
        fi
    fi

    # Check if GPT deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $completionName &>/dev/null; then
        echo "$completionName already exists"
    else
        # Create GPT deployment
        echo "Creating $completionName deployment"
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $completionName \
            --model-format OpenAI \
            --model-name $completionName \
            --model-version $completionModelVersion; then
            echo "Failed to create $completionName"
            exit 1
        fi
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