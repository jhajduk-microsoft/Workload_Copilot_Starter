#!/bin/bash

set -a
source ../.env
set +a

resourceGroupName=$AZURE_RESOURCE_GROUP
aiHubName=$WORKSPACE_NAME

az ml connection create --resource-group $resourceGroupName --workspace-name $aiHubName --f ./connections_yaml/azure_ai_search.yaml
az ml connection create  --resource-group $resourceGroupName --workspace-name $aiHubName --f ./connections_yaml/azure_openai_service.yaml