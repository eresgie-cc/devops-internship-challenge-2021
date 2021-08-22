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
