output "website_url" {
  description = "The URL of the static website hosted on Azure Storage"
  value       = azurerm_storage_account.storage.primary_web_endpoint
}


output "function_app_name" {
  description = "The name of the Serverless Function App"
  value       = azurerm_linux_function_app.fn_app.name
}

output "api_url" {
  description = "The URL of the API endpoint for getting visitor count"
  value       = "https://${azurerm_linux_function_app.fn_app.default_hostname}/api/get_count"
}

output "cdn_url" {
  description = "The secure HTTPS URL of the CDN endpoint"
  value       = "https://${azurerm_cdn_endpoint.cdn_endpoint.fqdn}"
}
