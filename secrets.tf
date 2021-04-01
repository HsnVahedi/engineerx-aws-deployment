resource "kubernetes_secret" "postgres_password" {
  metadata {
    name = "postgres-password"
    labels = {
      role = "deployment"
    }
  }

  data = {
    password = var.postgres_password
  }
}

resource "kubernetes_secret" "django_secret_key" {
  metadata {
    name = "django-secret-key"
    labels = {
      role = "deployment"
    }
  }

  data = {
    secret_key = var.django_secret_key
  }
}

resource "kubernetes_secret" "dockerhub_cred" {
  metadata {
    name = "dockerhub-cred"
    labels = {
      role = "deployment"
    }
  }

  data = {
    ".dockerconfigjson" = <<DOCKER
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "${base64encode("${var.dockerhub_username}:${var.dockerhub_password}")}"
    }
  }
}
DOCKER
  }

  type = "kubernetes.io/dockerconfigjson"
}