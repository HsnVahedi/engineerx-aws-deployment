resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"

    labels = {
      app  = "frontend"
      role = "deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "frontend"
      }
    }

    template {
      metadata {
        labels = {
          app  = "frontend"
          role = "deployment"
        }
      }

      spec {

        container {
          name    = "frontend"
          image   = "hsndocker/frontend:${var.frontend_version}"
          command = ["/bin/sh", "-c", "npm run build && npm run start"]

          port {
            container_port = 3000
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
            name  = "BACKEND_URL"
            value = "backendingress"
          }

          env {
            name  = "BACKEND_PORT"
            value = "80"
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "3000"
            }

            initial_delay_seconds = 100
            period_seconds        = 5
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "3000"
            }

            initial_delay_seconds = 120
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

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      role = "deployment"
    }
  }

  spec {
    port {
      port        = 80
      target_port = "3000"
    }

    selector = {
      app = "frontend"
    }

  }
}

resource "kubernetes_deployment" "ingress" {
  metadata {
    name = "ingress"

    labels = {
      app  = "ingress"
      role = "deployment"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "ingress"
      }
    }

    template {
      metadata {
        labels = {
          app  = "ingress"
          role = "deployment"
        }
      }

      spec {

        container {
          name  = "nginx"
          image = "hsndocker/nginx:${var.frontend_version}"

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

        }
        image_pull_secrets {
          name = kubernetes_secret.dockerhub_cred.metadata[0].name
        }
      }
    }
  }
}