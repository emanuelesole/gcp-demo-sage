resource "google_firestore_database" "database" {
  project     = var.project_id
  name        = local.firestore_database
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  # Il default del provider è ABANDON: un destroy lascerebbe il database in piedi.
  deletion_policy = "DELETE"

  depends_on = [google_project_service.apis]
}

resource "google_firestore_index" "chunks_embedding" {
  project     = var.project_id
  database    = google_firestore_database.database.name
  collection  = var.firestore_collection
  query_scope = "COLLECTION"

  fields {
    field_path = "embedding"

    vector_config {
      dimension = var.embedding_dimension
      flat {}
    }
  }

  # Dopo la creazione l'API restituisce i campi dell'indice in forma diversa (aggiunge
  # `__name__`), e il provider lo legge come una differenza che forza la ricreazione
  # dell'indice a ogni plan. Un indice vettoriale non è modificabile in-place comunque.
  lifecycle {
    ignore_changes = [fields]
  }
}