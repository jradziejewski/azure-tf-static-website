output "website_url" {
  description = "The URL of the static website hosted on Azure Storage"
  value       = azurerm_storage_account.storage.primary_web_endpoint
}


output "function_app_name" {
  description = "The name of the Serverless Function App"
  value       = azurerm_linux_function_app.fn_app.name
}
