variable "region" {
  type    = string
  default = "eu-central-1"
}

// VPC
variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

// public
variable "public_cidr" {
  type    = string
  default = "10.10.1.0/24"
}

// private
variable "private_cidr" {
  type    = list(string)
  default = ["10.10.10.0/24", "10.10.20.0/24", "10.10.30.0/24"]
}

variable "av_zones" {
  description = "avaibility zones"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

// bastion
variable "bastion_ip" {
  type    = string
  default = "10.10.1.10"
}
variable "bastion_key_name" {
  type    = string
  default = "DEV-CLUSTER"
}

variable "ip_to_bastion" {
  type    = string
  default = "161.35.212.75"
}
