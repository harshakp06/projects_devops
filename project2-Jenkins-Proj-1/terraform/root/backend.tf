terraform {
  backend "azurerm" {
      resource_group_name  = "tfstate"
      storage_account_name = "tfstateh1d7a"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}



