import os
import yaml

with open('connection.yaml', 'r') as file:
    config = yaml.safe_load(file)

config['api_key'] = os.getenv('AOAIApiKey')
config['endpoint'] = os.getenv('AOAIendpoint')