resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
    labels = {
      role = "deployment"
    }
  }
  storage_provisioner = "efs.csi.aws.com"
}

resource "kubernetes_persistent_volume" "media_efs_pv" {
  metadata {
    name = "media-efs" 
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
        volume_handle =  var.media_efs_id
      }
    }
  }
}

resource "kubernetes_persistent_volume" "static_efs_pv" {
  metadata {
    name = "static-efs" 
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
        volume_handle =  var.static_efs_id
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "media_storage_claim" {
  metadata {
    name      = "media-efs" 
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

resource "kubernetes_persistent_volume_claim" "static_storage_claim" {
  metadata {
    name      = "static-efs" 
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