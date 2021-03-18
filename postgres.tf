resource "kubernetes_deployment" "backend_postgres" {
  metadata {
    name = "backend-postgres"

    labels = {
      app  = "backend-postgres"
      role = "deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend-postgres"
      }
    }

    template {
      metadata {
        labels = {
          app  = "backend-postgres"
          role = "deployment"
        }
      }

      spec {

        container {
          name  = "postgres"
          image = "hsndocker/backend-postgres:${var.backend_version}"

          resources {
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }

            requests = {
              memory = "64Mi"
              cpu    = "100m"
            }
          }

          port {
            container_port = 5432
          }

          env {
            name = "POSTGRES_PASSWORD"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.postgres_password.metadata[0].name
                key  = "password"
              }
            }
          }

        }

        image_pull_secrets {
          name = kubernetes_secret.dockerhub_cred.metadata[0].name
        }
      }
    }
  }
}

resource "kubernetes_service" "backend_postgres" {
  metadata {
    name = "backend-postgres"
    labels = {
      role = "deployment"
    }
  }

  spec {
    port {
      port        = 5432
      target_port = "5432"
    }

    selector = {
      app = "backend-postgres"
    }
  }
}