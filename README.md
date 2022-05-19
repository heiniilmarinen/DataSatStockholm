# Data Saturday Stockholm

In this repo you can find the pre-con exercises for **Less Clicking, More Coding! Azure Data Platform Development Using Infrastructure as Code**

## Getting started

You will need your favorite IDE for creating and editing your Terraform files. If you don't have one installed yet, Visual Studio Code is convenient to use. You can download it from [here](https://code.visualstudio.com/). If you are using VS Code, I also recommend to Install the HashiCorp Terraform extension.

In addition you will need Terrform, find the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started) for all major operating systems.

Lastly, to authenticate with Azure, you need Azure CLI, which you can download from [this link](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

Create a working directory, for example `terraform`, that you will start working in. You can also clone or fork this repo and create a working directory for creating your Terraform configuration.

## Authenticating to Azure 

For these exercises, you will need an Azure subscription that you can work with. We will use authentication with Azure CLI, so run the following to get logged in:

```
az login

# Check your default subscription
az account show

# If needed choose a different subscription
az account set -s "Your subscription name or id"
```


# 1. Initialization

Whenever you create a new Terraform project you will need to initialize it and setup your provider (in this case Azure).

Create `main.tf` file. It will have all basic configuration for your project.


## Terraform configuration
Usually provider and Terraform configuration are done in your `main.tf` file. Check the latest [Terraform Azure provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs). Add the following, you can update the provider to the latest, but note that it might require some changes in resource configurations as well.

```
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.5.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

## Initializing Terraform

We need to initialize Terraform to download all required modules and packages to be used.
You need to re-initialize every time you touch one of the modules, change versions etc...

```
terraform init
```

## Create your first Azure resource

In the `main.tf` file add your first resource configuration for a resource group and update with the name and location that you wish to use.

```
resource "azurerm_resource_group" "rg" {
  name = ""
  location = ""
}
```
When you are ready with your configuration, check your changes with `terraform plan`. 
To apply your changes run `terraform apply`.
To delete your resources run `terraform destroy`