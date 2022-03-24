terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.99.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = "Resourcegroupteam2"
  location = "Korea Central"
}
resource "azurerm_virtual_network" "virtualnetwork" {
  name                = "team2network"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_app_service_plan" "app-plan" {
  name                = "team2serviceplan"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service" "webapp" {
  name                = "team2-wep-app"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name
  app_service_plan_id = azurerm_app_service_plan.app-plan.id
  source_control {
    repo_url           = "https://github.com/WordPress/WordPress"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }

}
resource "azurerm_mysql_server" "mysql-server" {
  name                = "team2appserver"
  location            = azurerm_resource_group.resourcegroup.location
  resource_group_name = azurerm_resource_group.resourcegroup.name

  administrator_login          = "team2admin"
  administrator_login_password = "P@ssw0rd1234"

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = false
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = false
  ssl_minimal_tls_version_enforced  = "TLSEnforcementDisabled"
}

resource "azurerm_mysql_database" "app-db" {
  name                = "team2appdp"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  server_name         = azurerm_mysql_server.mysql-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_public_ip" "publicip" {
  name                = "PublicIPForLB"
  location            = "Korea Central"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "Team2LoadBalancer"
  location            = "Korea Central"
  resource_group_name = azurerm_resource_group.resourcegroup.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
}

#create NFS storage

resource "azurerm_storage_account" "example" {
  name                     = "team2storagessss"
  resource_group_name      = azurerm_resource_group.resourcegroup.name
  location                 = azurerm_resource_group.resourcegroup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "example" {
  name                 = "team2share"
  storage_account_name = azurerm_storage_account.example.name
  quota                = 50
}