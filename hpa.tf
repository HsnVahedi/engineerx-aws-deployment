resource "kubernetes_horizontal_pod_autoscaler" "frontend_hpa" {
  metadata {
    name = "frontend-hpa"
  }

  spec {
    max_replicas = 30
    min_replicas = 1

    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "frontend"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "ingress_hpa" {
  metadata {
    name = "ingress-hpa"
  }

  spec {
    max_replicas = 30
    min_replicas = 1

    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "ingress"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "backend_hpa" {
  metadata {
    name = "backend-hpa"
  }

  spec {
    max_replicas = 30
    min_replicas = 1

    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "backend"
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "backend_ingress_hpa" {
  metadata {
    name = "backend-ingress-hpa"
  }

  spec {
    max_replicas = 30
    min_replicas = 1

    target_cpu_utilization_percentage = 50

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "backend-ingress"
    }
  }
}