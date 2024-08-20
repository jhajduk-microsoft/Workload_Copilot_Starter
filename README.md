# This is a starter framework for building a customer copilot

## Pre-requisites

VSCode or a code editor of your choice
Python (latest)
[These Python packages](https://learn.microsoft.com/en-us/azure/ai-studio/quickstarts/get-started-code?tabs=linux#install-the-prompt-flow-sdk)

## Setup Script

This script is used to set up the necessary resources for the application. It reads environment variables from a `.env` file and uses these variables to configure the resources. It will also write more variables to the `.env` file once complete. It is designed to be rerun in case of failure and to destroy the resources when desired.

## Environment Variables

The script requires the following environment variables:

- `TENANTID`: Your Azure Tenant ID.
- `SUBSCRIPTIONID`: Your Azure Subscription ID.
- `RESOURCEGROUP`: The name of the Azure Resource Group.
- `AOAINAME`: The name of the Azure OpenAI service.
- `LOCATION`: The location of your Azure resources (e.g., `westus`). Some models in AOAI are only available in certain regions and with certain version.
- `HUBNAME`: The name of the Azure Machine Learning Hub.
- `AZURE_OPENAI_EMBEDDING_DEPLOYMENT`: The name of the Azure OpenAI embedding deployment.
- `AZURE_OPENAI_EMBEDDING_MODEL_VERSION`: The version of the Azure OpenAI embedding model.

These variables should be defined in a `.env` file located in the parent directory of the script.

## Usage

Use the setup parameter to deploy the resources and use the destroy parameter to tear down the environment. To run the script, navigate to the infra directory containing the script and run the following command:

```bash
./setup.sh setup

./setup.sh destroy