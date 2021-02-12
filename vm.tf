resource "azurerm_network_interface" "network_interface_vm" {
  name                = "network_interface_vm"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.resources_internal.id
    private_ip_address_allocation = "Dynamic"
     
  }
  tags = {
        environment = "${var.environmenttag}"
    }
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = "${var.prefix}-win"
  resource_group_name = azurerm_resource_group.resources.name
  location            = azurerm_resource_group.resources.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "Password01"
  network_interface_ids = [
    azurerm_network_interface.network_interface_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
        environment = "${var.environmenttag}"
    }
}

output "azure_vm_public_ip" {
  value = azurerm_windows_virtual_machine.windows.public_ip_address
}


// add virtual machine - ubuntu 
resource "tls_private_key" "ubuntu_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

output "tls_private_key" { value = tls_private_key.ubuntu_ssh.private_key_pem }

// custom data 
locals {
  custom_data = <<CUSTOM_DATA
  #!/bin/bash
  echo "Execute your super awesome commands here!" >> /tmp/test.txt
  CUSTOM_DATA
  }

# Encode and pass you script


// end custom data 
// network interface creation
# Create public IPs
resource "azurerm_public_ip" "vm_ubuntu_public_ip" {
    name                         = "vm_ubuntu_public_ip"
    location            = azurerm_resource_group.resources.location
    resource_group_name = azurerm_resource_group.resources.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "${var.environmenttag}"
    }
} 
resource "azurerm_network_interface" "network_interface_ubuntu" {
  name                = "network_interface_ubuntu"
  location            = azurerm_resource_group.resources.location
  resource_group_name = azurerm_resource_group.resources.name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.resources_external.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_ubuntu_public_ip.id
     
  }
  tags = {
        environment = "${var.environmenttag}"
    }
}

// machine creation 
resource "azurerm_linux_virtual_machine" "ubuntuVM" {
    name                  = "ubuntuVM"
    location              = azurerm_resource_group.resources.location
    resource_group_name   = azurerm_resource_group.resources.name
    network_interface_ids = [azurerm_network_interface.network_interface_ubuntu.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.ubuntu_ssh.public_key_openssh
    }
     custom_data = base64encode(local.custom_data)
    //boot_diagnostics {
       // storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    //}

    tags = {
        environment = "${var.environmenttag}"
    }
}


