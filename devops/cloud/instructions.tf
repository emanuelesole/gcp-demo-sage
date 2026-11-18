locals {
  # Nome del bucket come richiesto dalla verifica: "<prefisso>instructions".
  instructions_bucket_name = "${var.resource_prefix}instructions"
}

# Bucket con il file istruzioni.md letto da Sage a ogni richiesta.
resource "google_storage_bucket" "instructions" {
  project  = var.project_id
  name     = local.instructions_bucket_name
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = true

  depends_on = [google_project_service.apis]
}

# Il service account di Cloud Run può solo leggere gli oggetti del bucket.
resource "google_storage_bucket_iam_member" "sage_run_instructions_viewer" {
  bucket = google_storage_bucket.instructions.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.sage_run.email}"
}