resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
    labels = {
      role = "deployment"
    }
  }
  storage_provisioner = "efs.csi.aws.com"
}

resource "kubernetes_persistent_volume" "efs_pv" {
  metadata {
    name = "efs" 
    labels = {
      role = "deployment"
    }
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "efs-sc"
    persistent_volume_source {
      csi {
        driver = "efs.csi.aws.com"
        volume_handle =  var.efs_id
      }
    }
    
  }

}

resource "kubernetes_persistent_volume_claim" "efs_storage_claim" {
  metadata {
    name      = "efs" 
    namespace = "storage"
    labels = {
      role = "deployment"
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