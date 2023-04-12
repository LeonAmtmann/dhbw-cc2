# Add outputs for Cosmos DB properties
output "cosmos_db_id" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.id
}

output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.endpoint
}

output "cosmos_db_endpoints_read" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.read_endpoints
}

output "cosmos_db_endpoints_write" {
  value = azurerm_cosmosdb_account.cc2_cosmosdb.write_endpoints
}

output "cosmos_db_primary_key" {
  sensitive = true
  value     = azurerm_cosmosdb_account.cc2_cosmosdb.primary_key
}

output "cosmos_db_secondary_key" {
  sensitive = true
  value     = azurerm_cosmosdb_account.cc2_cosmosdb.secondary_key
}

output "cosmos_db_primary_connection_string" {
  sensitive = true
  value     = azurerm_cosmosdb_account.cc2_cosmosdb.connection_strings[0]
}

# Add outputs for Cognitive Services properties
output "text_analytics_endpoint" {
  sensitive = true
  value = azurerm_cognitive_account.cog_text_analytics.endpoint
}

output "text_analytics_key1" {
  sensitive = true
  value = azurerm_cognitive_account.cog_text_analytics.primary_access_key
}

output "public_ip_address" {
  value = azurerm_public_ip.cc2_public_ip.ip_address
}
