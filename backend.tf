resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"

    labels = {
      app  = "backend"
      role = "deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "backend"
          role = "deployment"
        }
      }

      spec {
        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = locals.efs_pvc_name
          }
        }

        container {
          name    = "backend"
          image   = "hsndocker/backend:${var.backend_version}"
          command = ["bash"]
          args    = ["start.sh"]

          port {
            container_port = 8000
          }

          resources {
            limits = {
              cpu    = "1200m"
              memory = "1024Mi"
            }

            requests = {
              memory = "512Mi"
              cpu    = "700m"
            }
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

          volume_mount {
            name       = "data"
            mount_path = "/app/static"
            sub_path   = "static"
          }

          volume_mount {
            name       = "data"
            mount_path = "/app/media"
            sub_path   = "media"
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "8000"
            }

            initial_delay_seconds = 60
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "8000"
            }

            initial_delay_seconds = 100
            period_seconds        = 5
          }

        }

        image_pull_secrets {
          name = kubernetes_secret.dockerhub_cred.metadata[0].name
        }

      }
    }
  }
}

resource "kubernetes_deployment" "backend_ingress" {
  metadata {
    name = "backend-ingress"

    labels = {
      app  = "backend-ingress"
      role = "deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend-ingress"
      }
    }

    template {
      metadata {
        labels = {
          app  = "backend-ingress"
          role = "deployment"
        }
      }

      spec {
        volume {
          name = "data"

          persistent_volume_claim {
            claim_name = locals.efs_pvc_name
          }
        }

        container {
          name  = "backend-nginx"
          image = "hsndocker/backend-nginx:${var.backend_version}"

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
            container_port = 80
          }

          volume_mount {
            name       = "data"
            mount_path = "/home/app/web/static"
            sub_path   = "static"
          }

          volume_mount {
            name       = "data"
            mount_path = "/home/app/web/media"
            sub_path   = "media"
          }
        }
        image_pull_secrets {
          name = kubernetes_secret.dockerhub_cred.metadata[0].name
        }

      }
    }
  }
}