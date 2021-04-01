variable "backend_version" {
  type    = string
  default = "latest"
}

variable "frontend_version" {
  type    = string
  default = "latest"
}

variable "postgres_password" {
  type = string
}

variable "dockerhub_username" {
  type = string
}

variable "dockerhub_password" {
  type = string
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "django_secret_key" {
  type    = string
}

variable "host" {
  type    = string
}
