output "container_ids" {
  value = { for name, container in azurerm_storage_container.tfstate : name => container.id }
}
