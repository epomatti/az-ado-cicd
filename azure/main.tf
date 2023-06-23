terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.62.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.39.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {}

data "azuread_client_config" "current" {}

locals {
  owner_object_id = data.azuread_client_config.current.object_id
}

### Group ###

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}"
  location = var.location
}

### ADO Service Connector ###

resource "random_uuid" "oauth2_permission_scope_backend" {}

resource "azuread_application" "ado_service_connector" {
  display_name     = "ADO Service Connector"
  sign_in_audience = "AzureADMyOrg"
  owners           = [local.owner_object_id]
}

resource "azuread_service_principal" "ado_service_connector" {
  application_id               = azuread_application.ado_service_connector.application_id
  app_role_assignment_required = false
  owners                       = [local.owner_object_id]

  feature_tags {
    enterprise = true
  }
}

### Role Assignment ###

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_assignment" "ado_service_connector" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.ado_service_connector.id
}


### Backend ###

resource "azurerm_service_plan" "main" {
  name                = "plan-backend-${var.workload}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "B1"
  worker_count        = 1
}

resource "azurerm_linux_web_app" "main" {
  name                = "app-backend-${var.workload}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  https_only          = true

  site_config {
    always_on = true

    application_stack {
      dotnet_version = "7.0"
    }

    cors {
      allowed_origins = ["*"]
    }
  }

  app_settings = {
    ASPNETCORE_ENVIRONMENT   = "Development"
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  lifecycle {
    ignore_changes = [
      auth_settings_v2
    ]
  }
}

### Frontend  ###

resource "azurerm_static_site" "frontend" {
  name                = "stapp-${var.workload}"
  resource_group_name = azurerm_resource_group.main.name
  location            = "West Europe"
  sku_size            = "Free"
  sku_tier            = "Free"
}
