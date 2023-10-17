resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

resource "random_string" "container_name" {
  length  = 25
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name_prefix}-${random_string.container_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"] # Replace with your desired address space

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24" # Replace with your desired subnet address prefix
  }
}

resource "azurerm_container_group" "container" {
  name                = "${var.container_group_name_prefix}-${random_string.container_name.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  os_type             = "Linux"
  restart_policy      = var.restart_policy

  container {
    name   = "${var.container_name_prefix}-${random_string.container_name.result}"
    image  = var.image
    cpu    = var.cpu_cores
    memory = var.memory_in_gb

    ports {
      port     = var.port
      protocol = "TCP"
    }
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    dns_config {
      name_servers = ["10.0.0.4"] # Replace with your DNS server address
    }

    ip_configuration {
      name                 = "internal"
      subnet_id            = azurerm_virtual_network.vnet.subnet.id
      public_ip_address_id = null
    }
  }
}

