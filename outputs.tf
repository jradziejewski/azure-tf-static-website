output "website_url" {
  description = "The URL of the static website hosted on Azure Storage"
  value       = azurerm_storage_account.storage.primary_web_endpoint
}
