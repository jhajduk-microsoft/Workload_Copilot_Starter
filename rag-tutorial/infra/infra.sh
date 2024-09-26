#!/bin/bash

# Export environment variables
set -a
source ../.env
set +a

# Variables (replace <subscriptionID> with your actual Azure subscription ID)
# Define the list of variables
variables=(
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
    completionName=$AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME
    completionModelVersion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
    searchName=$AZUREAI_SEARCH_NAME
    searchServiceSku=$AZUREAI_SEARCH_SKU
)

# Iterate through the list of variables
for variable in "${variables[@]}"; do
    # Check if the variable is empty
    if [[ -z $variable ]]; then
        echo "One or more variables are empty: $variable"
        exit 1
    fi
done

# Assign the variables
tenant=$TENANT_ID
subscriptionID=$AZURE_SUBSCRIPTION_ID
resourceGroupName=$AZURE_RESOURCE_GROUP
aiHubName=$WORKSPACE_NAME
aiServices=$AZUREAI_SERVICES_NAME
aoaiName=$AZURE_OPENAI_NAME
location=$LOCATION
projectName=$WORKSPACE_PROJECT_NAME
openaiSkuName=$AZURE_OPENAI_SKU_NAME
embeddingName=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT
embeddingModelVersion=$AZURE_OPENAI_EMBEDDING_MODEL_VERSION
completionName=$AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME
completionModelVersion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
searchName=$AZUREAI_SEARCH_NAME
searchServiceSku=$AZUREAI_SEARCH_SKU

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
        echo "AI Hub $aiHubName already exists"
    else
        # Create Azure AI Hub resource
        echo "Creating AI Hub $aiHubName"
        if ! az ml workspace create \
            --resource-group $resourceGroupName \
            --name $aiHubName \
            --kind hub; then
            echo "Failed to create AI Hub $aiHubName"
            exit 1
        fi
    fi

    # Check if project resource exists
    if az ml workspace show \
        --name $projectName \
        --workspace-name $aiHubName \
        --resource-group $resourceGroupName &>/dev/null; then
        echo "Project $projectName already exists"
    else
        hubID=$(az resource show --name $aiHubName --resource-group $resourceGroupName --resource-type Microsoft.MachineLearningServices/workspaces --query id --output tsv)
        # Create project resource
        echo "Creating Project $projectName"
        if ! az ml workspace create \
            --kind project \
            --hub-id $hubID\
            --resource-group $resourceGroupName \
            --name $projectName; then          
        echo "Failed to create Project $projectName"
        exit 1
        fi
    fi

# Check if Azure OpenAI resource exists
    if az cognitiveservices account show \
        --name $aoaiName \
        --resource-group \
        $resourceGroupName &>/dev/null; then
        echo "Azure OpenAI Service $aoaiName already exists"
    else
        # Create Azure OpenAI resource
        echo "Creating Azure OpenAI Service $aoaiName"
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
        echo "embedding $embeddingName already exists"
    else
        echo "Creating embedding $embeddingName deployment"
        # Create embedding deployment
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $embeddingName \
            --model-format OpenAI \
            --model-name $embeddingName \
            --model-version $embeddingModelVersion; then
            echo "Failed to create embedding $embeddingName"
            exit 1
        fi
    fi

    # Check if GPT deployment exists
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $completionName &>/dev/null; then
        echo "GPT deployment $completionName already exists"
    else
        # Create GPT deployment
        echo "Creating GPT deployment $completionName deployment"
        if ! az cognitiveservices account deployment create \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $completionName \
            --model-format OpenAI \
            --model-name $completionName \
            --model-version $completionModelVersion; then
            echo "Failed to create GPT deployment $completionName"
            exit 1
        fi
    fi

    # Check if Azure AI Search resource exists
    if az search service show \
         --name $searchName \
         --resource-group $resourceGroupName &>/dev/null; then
        echo "Search Service $searchName already exists"
    else
        # Create Azure AI Search resource
        echo "Creating Search Service $searchName"
        if ! az search service create \
            --name $searchName \
            --resource-group $resourceGroupName \
            --location $location \
            --sku $searchServiceSku \
            --subscription $subscriptionID; then
            echo "Failed to create Search Service $searchName"
            exit 1
        fi
    fi

    #Retrieve the REST API endpoint URL
    AOAIendpoint=$(az cognitiveservices account show --name $aoaiName --resource-group $resourceGroupName --query "properties.endpoint" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve AOAI endpoint URL"
        exit 1
    fi
    echo >> ../.env
    echo "AZURE_OPENAI_ENDPOINT=$AOAIendpoint" >> ../.env

    # Retrieve the primary API key
    AOAIApiKey=$(az cognitiveservices account keys list --name $aoaiName --resource-group $resourceGroupName --query "key1" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve AOAI API key"
        exit 1
    fi
    echo "AZURE_OPENAI_API_KEY=$AOAIApiKey" >> ../.env

    # Retrieve the Azure AI Search endpoint
    searchEndpoint=$(az search service show --name $searchName --resource-group $resourceGroupName --query "properties.url" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Azure AI Search endpoint"
        exit 1
    fi
    echo "AZUREAI_SEARCH_ENDPOINT=https://$searchName.search.windows.net" >> ../.env

    # Retrieve the admin key for Azure AI Search
    searchAdminKey=$(az search admin-key show --service-name $searchName --resource-group $resourceGroupName --query "primaryKey" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Azure AI Search Admin Key"
        exit 1
    fi
    echo "AZUREAI_SEARCH_ADMIN_KEY=$searchAdminKey" >> ../.env

    # Call Python script for Azure AI Studio Connections
    if ! python3 ./connections_yaml/azure_ai_studio_connection_handler.py; then
        echo "Failed to execute replacements in connection yaml files"
        exit 1
    fi

    # Wait for 10 seconds
    sleep 10

    if ! bash ./connections_yaml/create_azure_ai_connections.sh; then
        echo "Failed to create connections in Azure AI Studio script"
        exit 1
    fi

    
    echo "Resources created successfully"


fi

# Check if the flag is set to destroy resources
if [ "$1" == "destroy" ]; then
    # Destroy resources
    echo "Destroying resources..."
    
# May have to delete deployments first...
    # Delete embedding deployment
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $embeddingName &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $embeddingName

        echo "Embedding deployment $embeddingName deleted"
    else
        echo "Embedding deployment $embeddingName does not exist"
    fi

    # Delete GPT deployment
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $aoaiName \
        --deployment-name $completionName &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $aoaiName \
            --deployment-name $completionName

        echo "GPT deployment $completionName deleted"
    else
        echo "GPT deployment $completionName does not exist"

    fi

    # Delete resource group
    if az group show --name $resourceGroupName &>/dev/null; then
        az group delete \
            --name $resourceGroupName

        echo "Resource group $resourceGroupName deleted"
    else
        echo "Resource group $resourceGroupName does not exist"
    fi

fi