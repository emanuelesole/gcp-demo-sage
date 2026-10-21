variable "container_image" {
  description = "Immagine del container da deployare. Il default è un'immagine placeholder, utile per il primo apply quando il repository è ancora vuoto."
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

resource "google_cloud_run_v2_service" "this" {
  project  = var.project_id
  name     = var.resource_prefix
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  deletion_protection = false

  template {
    service_account = google_service_account.this.email

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = "1"
          memory = "2Gi"
        }
      }

      env {
        name  = "GOOGLE_CLOUD_PROJECT"
        value = var.project_id
      }

      env {
        name  = "GOOGLE_CLOUD_LOCATION"
        value = var.region
      }
    }
  }

  # Evita che terraform riporti l'immagine al placeholder dopo deploy esterni (CI/CD)
  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      client,
      client_version,
    ]
  }

  depends_on = [
    google_project_service.apis,
    google_project_iam_member.vertex_ai_user,
  ]
}

# Decommenta per rendere il servizio pubblico (senza autenticazione)
# resource "google_cloud_run_v2_service_iam_member" "public" {
#   project  = var.project_id
#   location = var.region
#   name     = google_cloud_run_v2_service.this.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }
