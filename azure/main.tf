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
# provider "azapi" {}

data "azuread_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

locals {
  tenant_id = data.azuread_client_config.current.tenant_id
  # msgraph_application_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  owner_object_id = data.azuread_client_config.current.object_id
}

### Group ###

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.workload}"
  location = var.location
}


### Shared ###

# resource "azuread_user" "main" {
#   user_principal_name = var.user_principal
#   display_name        = var.user_display_name
#   password            = var.user_password
# }

# resource "azuread_service_principal" "msgraph" {
#   application_id = local.msgraph_application_id
#   use_existing   = true
# }

# ### Backend App Registration ###

# resource "random_uuid" "oauth2_permission_scope_backend" {}

# resource "azuread_application" "backend" {
#   display_name     = "spabackend"
#   identifier_uris  = ["api://spabackend"]
#   sign_in_audience = "AzureADMyOrg"
#   owners           = [local.owner_object_id]

#   api {
#     requested_access_token_version = 2

#     oauth2_permission_scope {
#       id                         = random_uuid.oauth2_permission_scope_backend.result
#       enabled                    = true
#       type                       = "User"
#       admin_consent_display_name = "Admin Consent"
#       admin_consent_description  = "Admin Consent description"
#       value                      = "user_impersonation"
#     }
#   }

#   required_resource_access {
#     resource_app_id = local.msgraph_application_id

#     resource_access {
#       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
#       type = "Scope"
#     }
#   }
# }

# resource "azuread_service_principal" "backend" {
#   application_id               = azuread_application.backend.application_id
#   app_role_assignment_required = false
#   owners                       = [local.owner_object_id]

#   feature_tags {
#     enterprise = true
#   }
# }

# resource "azuread_application_password" "backend" {
#   application_object_id = azuread_application.backend.object_id
# }


# ### Backend WebApp ###

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
    # APP_REGISTRATION_SECRET  = azuread_application_password.backend.value
    ASPNETCORE_ENVIRONMENT   = "Development" # For testing purposes
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  lifecycle {
    ignore_changes = [
      auth_settings_v2
    ]
  }
}

# ### Frontend App Registration ###

# resource "random_uuid" "oauth2_permission_scope_frontend" {}

# resource "azuread_application" "frontend" {
#   display_name     = "spafrontend"
#   identifier_uris  = ["api://spafrontend"]
#   sign_in_audience = "AzureADMyOrg"
#   owners           = [local.owner_object_id]

#   single_page_application {
#     redirect_uris = ["http://localhost:4200/", var.staticsite_redirect_uri]
#   }

#   api {
#     requested_access_token_version = 2

#     oauth2_permission_scope {
#       id                         = random_uuid.oauth2_permission_scope_frontend.result
#       enabled                    = true
#       type                       = "User"
#       admin_consent_display_name = "Admin Consent"
#       admin_consent_description  = "Admin Consent description"
#       value                      = "user_impersonation"
#     }
#   }

#   required_resource_access {
#     resource_app_id = local.msgraph_application_id

#     resource_access {
#       id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read"]
#       type = "Scope"
#     }
#   }

#   required_resource_access {
#     resource_app_id = azuread_application.backend.application_id

#     resource_access {
#       id   = azuread_application.backend.oauth2_permission_scope_ids["user_impersonation"]
#       type = "Scope"
#     }
#   }
# }

# resource "azuread_service_principal" "frontend" {
#   application_id               = azuread_application.frontend.application_id
#   app_role_assignment_required = false
#   owners                       = [local.owner_object_id]

#   feature_tags {
#     enterprise = true
#   }
# }

# resource "azuread_application_password" "frontend" {
#   application_object_id = azuread_application.frontend.object_id
# }
