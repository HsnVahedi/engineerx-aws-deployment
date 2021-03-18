variable "backend_version" {
    type = string
}

variable "frontend_version" {
    type = string
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

variable "media_efs_id" {
  type = string 
}

variable "static_efs_id" {
  type = string 
}