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

To delete your resources run `terraform destroy`.



# 2. Create your first resource

What are the resources that you are going to need for your data solution? We are going to start creating specific resources through these exercises, but feel free to focus on the resources that are most relevant to you. The important thing is not the specific resource you use in each part of the exercise, but that you practice each skill in the exercise.

Let's start by creating an Azure SQL database, first check the Terraform provider information for the [resource](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database) and check what information you need.

According to the sample you are going to need a sql server resource as well as a database resource. Also, you might notice that there is an auditing policy configured as well, you can decide if you want to use it or not. 

1. Start with creating a `sql.tf` file. 

2. Create a resource block with type `azurerm_mssql_server` and name `sql' and add the required parameters:

```
name = "sql-your-unique-name"

resource_group_name = azurerm_resource_group.rg.name
location            = azurerm_resource_group.rg.location

version                      = "12.0"
administrator_login          = "sqladmin"
administrator_login_password = "random2o342874!"
```
Note that we are able to reference other terraform resources with `resource_type.resource_name.property`. We use this method to get the resource group name and location.

Also, this is not the best place for secrets, but we'll return to this at a later point

3. In the `sql.tf` file, create a resource block with type azurerm_mssql_database and name this with parameters:
```
name      = "db-your-unique-name"
server_id =
sku_name  = "Basic"
```
We also need to reference the server we defined above. How can you reference the id of that server? **Hint:** Check how we referenced the resource group name and location.

## Add variables

We have started to possibly repeat some naming patterns across our resources, so it would make sense to define this as a variable.

1. Create a `variables.tf` file in your directory.

2. Define a variable block with name `env_name`, add `type = string` and `default = "your value to use in names of resources"`

3. Update your previous resources to reference this variable. You can for example update the database resource name to be
```
name      = "db-${var.env_name}"
```

## Add outputs

There might also be some values from our resources that we might need to print out after a deployment process or we might need to reference a value from a separate Terraform configuration. In that case we need outputs.

1. Create a `output.tf` file in your directory.

2. Create an output block named `sql-endpoint` with the following parameter:
```
value = azurerm_mssql_server.this.fully_qualified_domain_name
```

## Terraform validate

When you are making bigger changes to your Terraform confguration, it is a good idea to validate it with `terraform validate`. After this you can proceed with `terraform plan` and `terraform apply` steps as usual.



# 3. Handle existing resources

Create a resource of your choosing, for example Data Factory in your resource group through the Azure portal or Azure CLI in the same resource group you created previously. Try running `terraform plan` after this and see what happens.

Terraform will not become automatically aware of new resources, instead they need to be imported to Terraform state. 

Find the Terraform documentation page for the resource you chose to create. Grab the sample from the documentation, but change the terraform name for the resource to what you would like it to be, for example df for Data Factory. Now run `terraform plan` again, Terraform will think that it will have to create these resources.

Find the import section on the Terraform documentation and verify how the resource should be imported. You can find the Terraform resource reference from the plan and then you will need to fetch the resource id from the Azure portal. Your import command should look something like this:

```
terraform import azurerm_data_factory.df /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/example/providers/Microsoft.DataFactory/factories/df-your-unique-name
```


# 4. Using modules

You can find a Key Vault module in this reository in the modules folder. Add this module to your code base as well, ensure that the module contents stay in their own folder.

## Calling the key vault child module

To use the above module we will have to call it from our root module. The Key Vault module defines some variables that don't have default values. These will have to be defined when calling from the child module. In the main directory where you initially started working (this is where you have your `sql.tf` file), add a `kv.tf` file. In the file add the following configuration:

```
module "kv" {
  source = "./modules/key_vault"

  name     = var.env_name
  rg_name  = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
}
```

Make sure the source is correctly pointing to the directory where the key vault child module is located. 

### Bonus task

Create your own module for a purpose where you think a module would be useful.

## Handling secrets 

Since we created a Key Vault there is now a chance to create secrets in the Key Vault. There are multiple ways to handle secrets in Terraform and here we will look at one way that can be used. We will use the random resource provider to create a secret and then store it in the key vault. You can find the provider documentation [here](https://registry.terraform.io/providers/hashicorp/random/latest/docs)

Check which resource from the random provider we could use for generating the secret and check how this provider can be used.

We will have to first tell Terraform, that we want to use this second provider. Find where you have defined that you will use the Azure provider (`main.tf`). In the required_providers block add the following:

```
random = {
    source = "hashicorp/random"
}
```

Note that when you don’t specify a version, Terraform will use the latest version available.

Whenever you add a new provider or update the version, you will have to rerun `terraform init`. After running this, you are ready to use the provider.

In the `kv.tf` file, add a new resource block as follows:
```
resource "random_password" "sql_password" {
  length      = 16
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
}
```

We will want to store this password in Key Vault but to do that the user running the Terraform scripts would need access to create secrets in the Key Vault. In the `kv.tf` file use the `azurerm_client_config` to fetch the information about the user/service principal running these commands.

```
data "azurerm_client_config" "this" {
}
```

We can then create a role assignment to the Key Vault, add the following to the kv.tf file:

```
resource "azurerm_role_assignment" "kv_admin" {
  scope                = 
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.this.object_id
}
```

Note how we reference the data block with data.azurerm_client_config.this.object_id. How should you set the scope so that you reference the Key Vault created by the module?

Lastly we need to create the secret to the Key Vault based on the password we created with the random provider.

```
resource "azurerm_key_vault_secret" "sql_pw" {
  name         = "azsql"
  value        = 
  key_vault_id = 

  depends_on = [
    azurerm_role_assignment.kv_user
  ]
}
```

How should you reference the Key Vault id and the result of the password generated by the provider?

To reference this secret in you Azure SQL resource, navigate to the sql.tf file and change the reference to the admin password as follows: `administrator_login_password = azurerm_key_vault_secret.sql_pw.value`

Remember to save the files you have made changes to and check that the configuration is valid with `terraform validate`

Now you can proceed by checking the changes with `terraform plan` and `terraform apply`.
