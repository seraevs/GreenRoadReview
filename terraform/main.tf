# Define Terraform settings and required providers
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # Designate the Terraform provider for Azure
      version = "~> 3.58.0" # Specify the version of the Azure provider
    }
  }

  backend "azurerm" {
    resource_group_name  = "GreenRoad"             # Name of the Azure resource group for the Terraform state file
    storage_account_name = "greenroad"             # Azure Storage Account name for state management
    container_name       = "greenroad"             # Blob container name in the Storage Account for the state file
    key                  = "terraform.tfstate"     # The state file name
    access_key           = "QtgXHUbT0wJ1K60UqdDc3bNx8hbR6+PELhK2DbLmXQyq+uzHsYt0ATO4Nd+GbpIvga6SQgnG/lST+AStnnDS1g==" 
    # Note: The access key is hardcoded for demonstration; in production, use a secure method
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true # Option to skip automatic provider registration 
   # Authentication details; in production, use environment variables for security
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}

# Define an Azure Resource Group
resource "azurerm_resource_group" "greenroad" {
  name     = "greenroad-resource-group" # Resource group name
  location = "eastus"                   # Location for the resource group
}

# Define a Virtual Network within the resource group
resource "azurerm_virtual_network" "greenroad" {
  name                = "greenroad-vnet"            # Virtual network name
  address_space       = ["10.0.0.0/16"]             # Address space for the virtual network
  location            = azurerm_resource_group.greenroad.location # Use resource group location
  resource_group_name = azurerm_resource_group.greenroad.name    # Associate with the defined resource group
}

# Define a subnet within the virtual network
resource "azurerm_subnet" "greenroad" {
  name                 = "greenroad-subnet"         # Subnet name
  resource_group_name  = azurerm_resource_group.greenroad.name # Associate with the defined resource group
  virtual_network_name = azurerm_virtual_network.greenroad.name # Specify the virtual network
  address_prefixes     = ["10.0.1.0/24"]            # CIDR block for the subnet
  depends_on = [azurerm_virtual_network.greenroad] # Terraform is its ability to have dependencies between resources, and even data sources.
}

# Define a public IP address for NAT Gateway
resource "azurerm_public_ip" "nat_ip_1" {
  name                = "example-nat-ip-1"          # Public IP address name
  location            = azurerm_resource_group.greenroad.location # Use resource group location
  resource_group_name = azurerm_resource_group.greenroad.name    # Associate with the defined resource group
  allocation_method   = "Static"                   # IP address allocation method
  sku                 = "Standard"                 # SKU for the public IP address
}

# Define a NAT Gateway and associate it with the public IP address
resource "azurerm_nat_gateway" "nat_gw_1" {
  name                = "example-nat-gw-1"          # NAT Gateway name
  location            = azurerm_resource_group.greenroad.location # Use resource group location
  resource_group_name = azurerm_resource_group.greenroad.name    # Associate with the defined resource group
}

resource "azurerm_nat_gateway_public_ip_association" "ng_ip_1_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw_1.id # Reference the NAT Gateway ID
  public_ip_address_id = azurerm_public_ip.nat_ip_1.id   # Reference the Public IP address ID
}

# Assigns the "Contributor" role at the subscription level
resource "azurerm_role_assignment" "contributor_assignment" {
  principal_id         = "c4a3959c-a452-4569-ae49-760933c05d5a" # The ID of the principal (user, group, or service principal) to assign the role to.
  role_definition_name = "Contributor" # The name of the role definition to assign. "Contributor" allows creating, updating, and deleting resources.
  scope                = "/subscriptions/d33de279-da28-4bb7-9317-f0a6d2fc6ab1" # The scope at which the role assignment applies, in this case, the entire subscription.
}

# Assigns the "Contributor" role at the resource group level
resource "azurerm_role_assignment" "resource_group_assignment" {
  principal_id         = "c4a3959c-a452-4569-ae49-760933c05d5a" # The ID of the principal to assign the role to.
  role_definition_name = "Contributor" # "Contributor" role, allowing management of resources within the specified scope.
  scope                = "${azurerm_resource_group.greenroad.id}" # The scope is limited to the specific resource group, defined by its ID.
}

# Assigns the "Reader" role at the subscription level
resource "azurerm_role_assignment" "reader_assignment" {
  principal_id         = "c4a3959c-a452-4569-ae49-760933c05d5a" # The ID of the principal to assign the role to.
  role_definition_name = "Reader" # The "Reader" role allows viewing but not modifying resources within the scope.
  scope                = "/subscriptions/d33de279-da28-4bb7-9317-f0a6d2fc6ab1" # The scope at which the role assignment applies, here it's the entire subscription.
}

# Output for the allocated IP address of the NAT Gateway's public IP
output "nat_gateway_public_ip_address" {
  value       = azurerm_public_ip.nat_ip_1.ip_address
  description = "The allocated IP address for the NAT Gateway's public IP."
}

# Output for the ID of the NAT Gateway's public IP resource
output "nat_gateway_public_ip_id" {
  value       = azurerm_public_ip.nat_ip_1.id
  description = "The resource ID for the NAT Gateway's public IP."
}

# Output Blocks 
output "nat_gateway_id" {
  value = azurerm_nat_gateway.nat_gw_1.id
  description = "The ID of the NAT Gateway"
}

output "nat_gateway_public_ip" {
  value = azurerm_public_ip.nat_ip_1.ip_address
  description = "The public IP address associated with the NAT Gateway"
}


