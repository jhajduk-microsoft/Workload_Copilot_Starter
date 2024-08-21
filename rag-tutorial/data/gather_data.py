import requests
from bs4 import BeautifulSoup
import os

def download_html(url, save_path):
    response = requests.get(url)
    if response.status_code == 200:
        with open(save_path, 'w', encoding='utf-8') as f:
            f.write(response.text)
        print(f"Downloaded: {save_path}")
    else:
        print(f"Failed to download {url}")

def scrape_links(base_url):
    doc_links = []
    response = requests.get(base_url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        # Look for documentation links; adjust the criteria as necessary
        for link in soup.find_all('a', href=True):
            # You might want to filter links to documentation pages specifically
            if "azure" in link['href'] and link['href'].startswith('http'):
                doc_links.append(link['href'])
    return doc_links

def main():
    base_url = 'https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/scenarios/azure-hpc/ready'  # Modify this as needed
    download_folder = 'AzureDocsHTML'
    
    if not os.path.exists(download_folder):
        os.makedirs(download_folder)
    
    links = scrape_links(base_url)
    for link in links:
        file_name = link.split('/')[-1] + '.html'  # Ensures the saved file has a .html extension
        save_path = os.path.join(download_folder, file_name)
        download_html(link, save_path)

if __name__ == '__main__':
    main()
