# Add the Azure Cosmos DB account configuration
resource "azurerm_cosmosdb_account" "cc2_cosmosdb" {
  name                = "cc2-cosmosdb"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }

  geo_location {
    location          = azurerm_resource_group.cc2_rg.location
    failover_priority = 0
  }
}