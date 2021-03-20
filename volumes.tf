resource "kubernetes_persistent_volume_claim" "media_storage_claim" {
  metadata {
    name      = "media-efs" 
    labels = {
      role = "efs-pv"
    }
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = "efs-sc"
  }
}

resource "kubernetes_persistent_volume_claim" "static_storage_claim" {
  metadata {
    name      = "static-efs" 
    labels = {
      role = "efs-pv"
    }
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = "efs-sc"
  }
}