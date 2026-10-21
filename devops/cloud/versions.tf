terraform {
  required_version = ">= 1.9.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Lo state remoto vive su Cloud Storage. Il nome del bucket è passato a `terraform init`
  # con `-backend-config=backend.hcl` (vedi backend.hcl.example) così non è hardcoded qui
  # e ogni studente può puntare al proprio bucket senza modificare il codice.
  backend "gcs" {}
}