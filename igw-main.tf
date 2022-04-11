# Accept the agreement for the mgmt-byol for R80.40
resource "azurerm_marketplace_agreement" "appsec-agreement" {
  count = var.appsec-agreement ? 0 : 1
  publisher = "checkpoint"
  offer = "infinity-gw"
  plan = "infinity-img"
}

# Create appsec resource group
resource "azurerm_resource_group" "rg-appsec" {
  name = "rg-${var.appsec-name}"
  location = var.location
}
resource "azurerm_resource_group_template_deployment" "template-deployment-appsec" {
  name                = "${var.appsec-name}-deploy"
  resource_group_name = azurerm_resource_group.rg-appsec.name
  deployment_mode     = "Complete"

  template_content    = file("files/appsec-template.json")
  parameters_content  = <<PARAMETERS
  {
    "location": {
        "value": "${azurerm_resource_group.rg-appsec.location}"
    },
    "vmName": {
        "value": "${var.appsec-name}"
    },
    "inboundSources": {
        "value": "0.0.0.0/0"
    },
    "authenticationType": {
        "value": "password"
    },
    "adminPassword": {
        "value": "${var.admin-pwd}"
    },
    "sshPublicKey": {
        "value": ""
    },
    "waapAgentToken": {
        "value": "${var.infinity-token}"
    },
    "waapAgentFog": {
        "value": ""
    },
    "vmSize": {
        "value": "${var.appsec-size}"
    },
    "diskType": {
        "value": "Standard_LRS"
    },
    "waapPublicIP": {
        "value": "yes"
    },
    "bootstrapScript": {
        "value": ""
    },
    "sourceImageVhdUri": {
        "value": "noCustomUri"
    },
    "vnetNewOrExisting": {
        "value": "existing"
    },
    "virtualNetworkExistingRGName": {
        "value": "${azurerm_virtual_network.vnet-north.resource_group_name}"
    },
    "virtualNetworkName": {
        "value": "${azurerm_virtual_network.vnet-north.name}"
    },
    "subnet1Name": {
        "value": "${azurerm_subnet.net-north-frontend.name}"
    },
    "subnet1Prefix": {
        "value": "${azurerm_subnet.net-north-frontend.address_prefixes[0]}"
    },
    "subnet2Name": {
        "value": "${azurerm_subnet.net-north-backend.name}"
    },
    "subnet2Prefix": {
        "value": "${azurerm_subnet.net-north-backend.address_prefixes[0]}"
    },
    "subnet2StartAddress": {
        "value": "10.10.1.4"
    }
  }
  PARAMETERS 
  depends_on = [azurerm_resource_group.rg-appsec,azurerm_subnet.net-north-frontend,azurerm_subnet.net-north-backend]
}

resource "azurerm_dns_a_record" "juiceshop-prod-record" {
  name                = "juiceshop-prod"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = ["1.2.3.4"]
  depends_on          = [azurerm_resource_group_template_deployment.template-deployment-appsec]
}
resource "azurerm_dns_a_record" "juiceshop-staging-record" {
  name                = "juiceshop-staging"
  zone_name           = azurerm_dns_zone.mydns-public-zone.name
  resource_group_name = azurerm_resource_group.rg-dns-myzone.name
  ttl                 = 300
  records             = ["1.2.3.4"]
  depends_on          = [azurerm_resource_group_template_deployment.template-deployment-appsec]
}

output "webapp-production-fqdn" {
    value = azurerm_dns_a_record.juiceshop-prod-record.fqdn
} 
output "webapp-staging-fqdn" {
    value = azurerm_dns_a_record.juiceshop-staging-record.fqdn
}
