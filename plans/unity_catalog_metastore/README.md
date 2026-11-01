# Unity Catalog Metastore

The region's Unity Catalog metastore, shared by every environment and owned by the metastore admins'
group. It has no storage of its own: each environment's catalog has its own storage root, so there is no
storage account, access connector or root credential here. Its destroy deletes it with whatever it still
holds (`force_destroy`).
