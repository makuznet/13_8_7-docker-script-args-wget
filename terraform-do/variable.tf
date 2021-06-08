variable "devs" {
  description = "prefix n login"
}

variable "rtoken" {
  description = "rebrain do token"
  type        = string
  sensitive   = true
}

variable "aws_akey" {
  description = "aws access key"
  type        = string
  sensitive   = true
}

variable "aws_skey" {
  description = "aws secret key"
  type        = string
  sensitive   = true
}

variable "login_user" {
  description = "login user"
  type        = string
  sensitive   = true
}

variable "d_region" {
  description = "region"
  type        = string
  default     = "fra1"
}

variable "d_image" {
  description = "droplet image"
  type        = string
  default     = "debian-10-x64"
}

variable "d_size" {
  description = "droplet size"
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "makuznet" {
  description = "my_ssh_key"
  type        = string
  sensitive   = true
}

variable "tag_1" {
  description = "rebrain tag 1"
  type        = string
  default     = "devops"
}
