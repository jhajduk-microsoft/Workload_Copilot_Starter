# This is a starter framework for building a customer copilot

## Pre-requisites
VSCode or a code editor of your choice
Python (latest)
[These Python packages](https://learn.microsoft.com/en-us/azure/ai-studio/quickstarts/get-started-code?tabs=linux#install-the-prompt-flow-sdk)

## Environment File

Create a .env file in the root of the repository containing all of the following:

- SUBSCRIPTIONID=<AzureSubscriptionId>
- RESOURCEGROUP=<ResourceGroupName>
- TENANTID=<TenantId>
- AZURE_OPENAI_ENDPOINT=endpoint_value
- AZURE_OPENAI_CHAT_DEPLOYMENT=chat_deployment_name
- AZURE_OPENAI_API_VERSION=api_version
- AZURE_OPENAI_EMBEDDING_DEPLOYMENT=embedding_model_deployment_name

## Infra

This folder contains the infrastructure deployment. You must be authenticated to your Azure tenant before deploying and have your subscription set in order to use it. It will deploy all of the necessary pieces to build your customer copilot. 