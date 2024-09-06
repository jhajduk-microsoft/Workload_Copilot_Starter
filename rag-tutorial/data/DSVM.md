# DSVM Usage Info

## Info about DSVM

This Linux based virtual machine contains popular tools for data science modeling and development activities. The main tools include Microsoft R Open, Anaconda Python distribution, Jupyter notebooks for Python and R, Postgres database, Azure command line tools, libraries to access various Azure services like AzureML, databases, Azure storage and big data services. It also has machine learning tools and algorithms like CNTK (a deep learning toolkit from Microsoft Research), Vowpal Wabbit and xgboost.

Jump start modeling and development for your data science project using software commonly used for analytics and machine learning tasks in a variety of languages including R, Python, SQL, Java and more all pre-installed. Jupyter notebooks offers a browser based experimentation and development environment for both Python and R. Microsoft R Open included in the VM. On the VM, the Azure SDK for Python, R, Java, node.js, Ruby, PHP allows you to build your applications using various Azure services in the cloud including the Cortana Intelligence Suite which is comprised of Azure Machine Learning, Azure data factory, Stream Analytics, SQL Datawarehouse, Hadoop, Data Lake, Spark and more. We also have other powerful machine learning tools and algorithms like CNTK (a deep learning toolkit from Microsoft Research), Vowpal Wabbit, xgboost pre-installed locally. Azure command line tools allow you to manage your Azure resources. Other development tools include run time for Ruby, PHP, node.js, Java, Perl, Eclipse, standard editors like vim, Emacs, gedit. A remote graphical desktop is also provided with VM side pre-configured (needs one time X2Go client side download). You have full access to the virtual machine and the shell including sudo access for the account that is created during the provisioning of the VM. This VM is built on top of Linux Openlogic CentOS-based version 7.2 distribution.

## Deployment commands

az group create --name exampleRG --location eastus
az deployment group create --resource-group exampleRG --template-file DSVM.bicep --parameters adminUsername=<admin-user> vmName=<vm-name>

## Creation of a Linux DSVM

To create an instance of either the Ubuntu 20.04 DSVM or the Azure DSVM for PyTorch:

- Go to the Azure portal. You might get a prompt to sign in to your Azure account if you haven't signed in yet.

- Find the VM listing by entering data science virtual machine. Then select Data Science Virtual Machine- Ubuntu 20.04 or Azure DSVM for PyTorch.

- Select Create.

- On the Create a virtual machine pane, fill in the Basics tab:

- Subscription: If you have more than one subscription, select the one on which the machine will be created and billed. You must have resource creation privileges for this subscription.

- Resource group: Create a new group or use an existing one.

- Virtual machine name: Enter the name of the VM. This name is used in your Azure portal.

- Region: Select the datacenter that's most appropriate. For fastest network access, the datacenter that hosts most of your data or is located closest to your physical location is the best choice. For more information, refer to Azure regions.

- Image: Don't change the default value.

- Size: This option should autopopulate with a size that's appropriate for general workloads. For more information, refer to Linux VM sizes in Azure.

Authentication type: For quicker setup, select Password.

 Note

- If you plan to use JupyterHub, make sure to select Password because JupyterHub is not configured to use Secure Shell (SSH) Protocol public keys.

- Username: Enter the administrator username. You use this username to sign in to your VM. It doesn't need to match your Azure username. Don't use capital letters.

 Important

- If you use capital letters in your username, JupyterHub won't work, and you'll encounter a 500 internal server error.

- Password: Enter the password you plan to use to sign in to your VM.

- Select Review + create.

- On the Review + create pane:

- Verify that all the information you entered is correct.
Select Create.
The provisioning process takes about 5 minutes. You can view the status of your VM in the Azure portal. 