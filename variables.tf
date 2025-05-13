variable "max_image_count" {
    type = number
    default = 500
}

variable "vpc_cidr" {
    type = string
}

variable "vpc_private_subnets" {
    type = string
}

variable "vpc_public_subnets" {
    type = string
}
