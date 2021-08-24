variable "region" {
  type    = string
  default = "eu-central-1"
}

// nodes
variable "private_subnet_id" {
  type    = list(string)
  default = [""]
}

variable "node_key_name" {
  type    = string
  default = "DEV-CLUSTER"
}

variable "sg_cluster_id" {
  type    = string
  default = ""
}

// alb
variable "public_id" {
  type    = list(string)
  default = [""]
}

variable "sg_alb_id" {
  type    = string
  default = ""
}

variable "vpc_id" {
  type    = string
  default = ""
}
