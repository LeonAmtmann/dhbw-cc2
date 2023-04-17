resource "azurerm_cognitive_account" "cog_text_analytics" {
  name                = "cc2-cog-text-analytics"
  location            = azurerm_resource_group.cc2_rg.location
  resource_group_name = azurerm_resource_group.cc2_rg.name
  kind                = "CognitiveServices"
  sku_name            = "S0"
}
