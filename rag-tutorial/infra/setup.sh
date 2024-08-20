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
hubname=$HUBNAME
hubskuname=$HUB_SKU_NAME
projectName=$PROJECT_NAME
embeddingname=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT
embeddingmodelversion=$AZURE_OPENAI_EMBEDDING_MODEL_VERSION
completionname=$AZURE_OPENAI_COMPLETION_DEPLOYMENT_NAME
completionmodelversion=$AZURE_OPENAI_COMPLETION_VERSION_NAME
searchName=$AZURE_AI_SEARCH_NAME
searchServiceSku=$SEARCH_SERVICE_SKU

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
        if ! az group create --name $resourceGroupName --location $location; then
            echo "Failed to create resource group"
            exit 1
        fi
    fi

    # Check if Azure AI Hub resource exists
    if az ml workspace show --name $hubname --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure AI Hub resource $hubname already exists"
    else
        # Create Azure AI Hub resource
        if ! az ml workspace create \
            --resource-group $resourceGroupName \
            --name $hubname \
            --kind hub; then
            echo "Failed to create Azure AI Hub resource"
            exit 1
        fi
    fi

    # Check if project resource exists
    if az ml project show --name $projectName --workspace-name $hubname --resource-group $resourceGroupName &>/dev/null; then
        echo "Project resource $projectName already exists"
    else
        # Create project resource
        if ! az ml project create \
            --name $projectName \
            --workspace-name $hubname \
            --resource-group $resourceGroupName; then
            echo "Failed to create project resource"
            exit 1
        fi
    fi

    # Check if connection exists
    if az ml project connection show \
        --name $connectionName \
        --workspace-name $hubname \
        --resource-group $resourceGroupName &>/dev/null; then
        echo "Connection $connectionName already exists"
    else
        # Create connection
        if ! az ml project connection create \
            --name $connectionName \
            --workspace-name $hubname \
            --resource-group $resourceGroupName \
            --type azure_search \
            --properties "{\"endpoint\":\"$searchEndpoint\",\"adminKey\":\"$searchAdminKey\"}"; then
            echo "Failed to create connection"
            exit 1
        fi
    fi

    # Check if Azure AI Search resource exists
    if az search service show --name $searchName --resource-group $resourceGroupName &>/dev/null; then
        echo "Azure AI Search resource $searchName already exists"
    else
        # Create Azure AI Search resource
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
fi

# Check if the flag is set to destroy resources
if [ "$1" == "destroy" ]; then
    # Destroy resources
    echo "Destroying resources..."

    # Delete the Azure AI Search connection
    if az ml project connection show \
        --name $connectionName \
        --workspace-name $hubname \
        --resource-group $resourceGroupName &>/dev/null; then
        az ml project connection delete \
            --name $connectionName \
            --workspace-name $hubname \
            --resource-group $resourceGroupName

        echo "Azure AI Search connection deleted"
    else
        echo "Azure AI Search connection does not exist"
    fi

    # Delete project resource
    if az ml project show --name $projectName --workspace-name $hubname --resource-group $resourceGroupName &>/dev/null; then
        az ml project delete \
            --name $projectName \
            --workspace-name $hubname \
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
        --deployment-name $completionname &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $resourceName \
            --deployment-name $completionname

        echo "Completion model deployment deleted"
    else
        echo "Completion model deployment does not exist"
    fi
    
    # Delete embedding model deployment
    if az cognitiveservices account deployment show \
        --resource-group $resourceGroupName \
        --name $resourceName \
        --deployment-name "deploy_ada" &>/dev/null; then
        az cognitiveservices account deployment delete \
            --resource-group $resourceGroupName \
            --name $resourceName \
            --deployment-name "deploy_ada"

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
if ! grep -q "AOAI_ENDPOINT=" ../.env; then
    AOAIendpoint=$(az cognitiveservices account show --name $resourceName --resource-group $resourceGroupName --query "properties.endpoint" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve AOAI endpoint URL"
        exit 1
    fi
    echo >> ../.env
    echo "AOAI_ENDPOINT=$AOAIendpoint" >> ../.env
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
if ! grep -q "SEARCH_ENDPOINT=" ../.env; then
    searchEndpoint=$(az search service show --name $searchName --resource-group $resourceGroupName --query "properties.url" -o tsv)
    if [ $? -ne 0 ]; then
        echo "Failed to retrieve Azure AI Search endpoint"
        exit 1
    fi
    echo "SEARCH_ENDPOINT=https://$searchName.search.windows.net" >> ../.env
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


echo "Script completed successfully"
