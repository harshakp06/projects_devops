# main tf file
resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "jenkins" {
  name     = "jenkins"
  location = "Central India"
}

/*resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate28745632"
  resource_group_name      = azurerm_resource_group.jenkins.name
  location                 = azurerm_resource_group.jenkins.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

 
}*/

/*
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
*/
#####

/*resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}*/  



resource "azurerm_virtual_network" "vnet_jenkins" {
  name                = "vnet-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
}

resource "azurerm_subnet" "subnet_jenkins" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.jenkins.name
  virtual_network_name = azurerm_virtual_network.vnet_jenkins.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "my_terraform_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "jenkins"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "jenkins_nic" {
  name                = "jenkins-nic2"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_terraform_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.jenkins_nic.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

data "azurerm_ssh_public_key" "azureprojects" {
  name                = "azureprojects"
  resource_group_name = "sshkey"
}

resource "azurerm_linux_virtual_machine" "jenkins" { 
  name                = "jenkins-machine"
  resource_group_name = azurerm_resource_group.jenkins.name
  location            = azurerm_resource_group.jenkins.location
  size                = "Standard_B2s"
                        # Standard_B2 # Standard_F2
  admin_username      = "adminuser"
  #user_data           = base64encode(templatefile("userdate.tftpl"))
  user_data           = base64encode(file("${path.module}/userdata.sh")) 
  network_interface_ids = [
    azurerm_network_interface.jenkins_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.azureprojects.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_linux_virtual_machine.jenkins.public_ip_address
}
