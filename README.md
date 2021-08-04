# Azure Managed Identity Pipelines

This repo showcases the possibility to leverage self-hosted build agents in Azure for both `Azure Pipelines` and `GitHub Actions`
without the need to specify Service Connections, VariableGroups, Action Secrets.

Still secrets will be securely managed in Azure KeyVault and are accessible for the self-hosted agent by leveraging MSI (Managed Service Identity).

## Set up your dev environment

If you are using VSCode, installed the Remote Container extension and have a Docker runtime installed you are ready to go with the provided devcontainer.

Otherwise you will need to install

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Bicep for Azure CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

## Set up your infrastructure

You will need access to an Azure Subscription or Resource Group with Owner rights.
If you don't have that yet you can create a free trial account [here](https://azure.microsoft.com/en-us/free/).



