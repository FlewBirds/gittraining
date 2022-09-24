variable "vpc_subnet_count" {
  type = number
  description = "no of subnets needed to create"
  default = 2
}

variable "vpc_pub_subnets_cidr_block" {
    type = list
  default = ["10.0.0.0/24","10.0.1.0/24"]
}

variable "vpc_prv_subnets_cidr_block" {
    type = list
  default = ["10.1.0.0/24","10.1.1.0/24"]
}