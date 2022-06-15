resource "azurerm_resource_group" "terra_rg" {
  name     = var.resourceGroupName
  location = var.azureRegion
}

resource "azurerm_virtual_network" "terra_vnet" {
  name                = var.vnetName
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terra_rg.location
  resource_group_name = azurerm_resource_group.terra_rg.name
}

resource "azurerm_subnet" "terra_subnet" {
  name                 = var.subnetName
  resource_group_name  = azurerm_resource_group.terra_rg.name
  virtual_network_name = azurerm_virtual_network.terra_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terra_nic" {
  name                = var.nicName
  location            = azurerm_resource_group.terra_rg.location
  resource_group_name = azurerm_resource_group.terra_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terra_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "VMpublicip1"
  resource_group_name = azurerm_resource_group.terra_rg.name
  location = var.azureRegion
  allocation_method   = "Static"
}
resource "azurerm_linux_virtual_machine" "terra_vm" {
  name                = var.vmName
  resource_group_name = azurerm_resource_group.terra_rg.name
  location            = azurerm_resource_group.terra_rg.location
  size                = var.vmSize
  admin_username      = var.vmUser
  network_interface_ids = [
    azurerm_network_interface.terra_nic.id,
  ]

  admin_ssh_key {
    username   = var.vmUser
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv4Lwm3kKJLxa/Il9d4M/TSkEHzjXjm0Ismufdr3BLfFtqyuUjhaHgezcaHX5TTQDrAAMrKW3G9plPM4XHtoXBnoBYnzsXS9U0T5XQzFHEnOVl3wKp9YTlb+/w92do/korMZWxkOqoqktxS4S+l2VMmgnO7sokGaUs2fc9ujaiCImVUFl627634rn5J//0JFklAP74R/N53M49EEOmP2JNBxoWqeiQyx9x2NY1vDpbz462taEKcG4+H0Kqohaw0gWCiVxAqTU83bl93zwNFpu2GkqD43O6Eo19jGX+cRgUp+hbvDFPhV3DapdcTBKowk3nFjP/JBSbuCBtui9s/q+9"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical" # az vm image list --output table
    offer     = "UbuntuServer" # az vm image list --offer UbuntuServer --all --output table
    sku       = "18.04-LTS" # az vm image list-skus --location westus --publisher Canonical --offer UbuntuServer --output table
    version   = "latest"
  }
}

