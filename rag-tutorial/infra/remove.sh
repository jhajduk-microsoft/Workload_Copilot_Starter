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

# Optionally, uncomment the following lines to clean up resources
az cognitiveservices account delete --name $resourceName --resource-group $resourceGroupName --yes || { echo "Failed to delete OpenAI resource"; exit 1; }
az group delete --name $resourceGroupName --yes --no-wait || { echo "Failed to delete resource group"; exit 1; }
