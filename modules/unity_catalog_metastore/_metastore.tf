# ===================================================================
# Unity Catalog Metastore
# ===================================================================
# One per region, shared by every environment. No metastore-level storage:
# each environment's catalog has its own storage root, on the environment's
# storage account (px-lakehouse-data), so the metastore needs no storage
# account, access connector or root credential. A root credential also kept
# Terraform from destroying the metastore: it deletes the credential first,
# which Databricks refuses while it is the root credential.

# Register metastore for region in Unity Catalog
resource "databricks_metastore" "uc_metastore" {
  provider = databricks.account
  name     = "${var.app_name}-dbr-metastore"
  region   = var.location
  # Owned by a humans-only group, whose members are the metastore admins
  owner = var.metastore_admins_group_name

  # A destroy deletes it with whatever it still holds. Set from the start: the
  # provider can't update a metastore (it sends a Delta Sharing token lifetime
  # the API refuses).
  force_destroy = true

  lifecycle {
    # The token lifetime is left at the account's default
    ignore_changes = [delta_sharing_recipient_token_lifetime_in_seconds]
  }
}
