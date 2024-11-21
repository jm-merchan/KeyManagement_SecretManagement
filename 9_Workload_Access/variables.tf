variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "gcp_auth_role_name" {
  default = "role1"
}