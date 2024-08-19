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

# Sign in to Azure CLI
az login --tenant $tenant || { echo "Failed to log in to Azure"; exit 1; }

# Create a resource group
az group create --name $resourceGroupName --location $location || { echo "Failed to create resource group"; exit 1; }

# Create Azure OpenAI resource
az cognitiveservices account create \
    --name $resourceName \
    --resource-group $resourceGroupName \
    --location $location \
    --kind OpenAI \
    --sku S0 \
    --subscription $subscriptionID || { echo "Failed to create OpenAI resource"; exit 1; }

# Deploy a model
az cognitiveservices account deployment create \
    --resource-group $resourceGroupName \
    --name $resourceName \
    --deployment-name "deploy_ada" \
    --model-name text-embedding-ada-002 \
    --model-version "2" \
    --model-format OpenAI \
    --sku-capacity "1" \
    --sku-name "Standard" || { echo "Failed to deploy model"; exit 1; }

az cognitiveservices account deployment create \
    --resource-group $resourceGroupName \
    --name $resourceName \
    --deployment-name "deploy_gpt_35" \
    --model-name gpt-35-turbo \
    --model-version "0613" \
    --model-format OpenAI \
    --sku-capacity "1" \
    --sku-name "Standard" || { echo "Failed to deploy model"; exit 1; }

az ml workspace create \
    --kind hub \
    --resource-group $resourceGroupName \
    --name $hubname

# Retrieve the REST API endpoint URL
AOAIendpoint=$(az cognitiveservices account show --name $resourceName --resource-group $resourceGroupName --query "properties.endpoint" -o tsv)
echo "ENDPOINT=$AOAIendpoint" >> ../.env
export $AOAIendpoint

# Retrieve the primary API key
AOAIApiKey=$(az cognitiveservices account keys list --name $resourceName --resource-group $resourceGroupName --query "key1" -o tsv)
echo "AOAIAPIKey: $AOAIApiKey" >> ../.env
export $AOAIAPIKey

python connection_helper.py

az ml connection create --file {connection.yml} --resource-group $resourceGroupName --workspace-name $hubname

echo "Script completed successfully"
