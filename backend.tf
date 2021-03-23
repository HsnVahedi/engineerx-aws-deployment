data "aws_db_instance" "database" {
  db_instance_identifier = "engineerx"
}

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
          name = "media"

          persistent_volume_claim {
            claim_name = "media-efs"
          }
        }

        volume {
          name = "static"

          persistent_volume_claim {
            claim_name = "static-efs" 
          }
        }

        # affinity {
        #   node_affinity {
        #     required_during_scheduling_ignored_during_execution {
        #       node_selector_term {
        #         match_expressions {
        #           key = "vpc.amazonaws.com/has-trunk-attached"
        #           operator = "In"
        #           values = ["true"]
        #         }
        #       }
        #     }
        #   }
        # }


        container {
          name    = "backend"
          image   = "hsndocker/backend:${var.backend_version}"
          command = ["/bin/bash", "-c", "rm manage.py && mv manage.prod.py manage.py && rm engineerx/wsgi.py && mv engineerx/wsgi.prod.py engineerx/wsgi.py && ./start.sh"]

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
          env {
            name = "POSTGRES_HOST"
            value = data.aws_db_instance.database.address
          }

          volume_mount {
            name       = "static"
            mount_path = "/app/static"
            # sub_path   = "static"
          }

          volume_mount {
            name       = "media"
            mount_path = "/app/media"
            # sub_path   = "media"
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

resource "kubernetes_service" "backend" {
  metadata {
    name = "backend"
    labels = {
      role = "deployment"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "8000"
    }

    selector = {
      app = "backend"
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
          name = "media"

          persistent_volume_claim {
            claim_name = "media-efs" 
          }
        }
        volume {
          name = "static"

          persistent_volume_claim {
            claim_name = "static-efs"
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
            name       = "static"
            mount_path = "/home/app/web/static"
            # sub_path   = "static"
          }

          volume_mount {
            name       = "media"
            mount_path = "/home/app/web/media"
            # sub_path   = "media"
          }
        }
        image_pull_secrets {
          name = kubernetes_secret.dockerhub_cred.metadata[0].name
        }

      }
    }
  }
}

resource "kubernetes_service" "backend_ingress" {
  metadata {
    name = "backendingress"
    labels = {
      role = "deployment"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "backend-ingress"
    }

  }
}