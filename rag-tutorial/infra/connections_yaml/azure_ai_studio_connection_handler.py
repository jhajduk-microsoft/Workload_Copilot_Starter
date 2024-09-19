from dotenv import load_dotenv
import os
import yaml

load_dotenv()

try:
    # Create the Azure AI Search connection
    yaml_file = {}
    yaml_file['name'] = os.getenv("AZUREAI_SEARCH_CONNECTION_NAME")
    yaml_file['type'] = 'azure_ai_search'
    yaml_file['endpoint'] = os.getenv("AZUREAI_SEARCH_ENDPOINT")
    yaml_file['api_key'] = os.getenv("AZUREAI_SEARCH_ADMIN_KEY")

    with open('./connections_yaml/azure_ai_search.yaml', 'w') as file:
        yaml.dump(yaml_file, file)
except:
    print("Unable to create Azure AI Search yaml file")

try:
    # Create the Azure OpenAI connection
    yaml_file = {}
    yaml_file['name'] = os.getenv("AZURE_OPENAI_CONNECTION_NAME")
    yaml_file['type'] = 'azure_open_ai'
    yaml_file['azure_endpoint'] = os.getenv("AZURE_OPENAI_ENDPOINT")
    yaml_file['api_key'] = os.getenv("AZURE_OPENAI_API_KEY")

    with open('./connections_yaml/azure_openai_service.yaml', 'w') as file:
        yaml.dump(yaml_file, file)
except:
    print("Unable to create Azure OpenAI yaml file")
