variable "default_tags" {
    type = map(string)
    default = {
        "env" = "smVPC"
    }
    description = "description for my varible"
}
variable "Public_subnet_count" {
    type = number
    description = "avoiding conflict"
    default = 2
}
variable "Private_subnet_count" {
    type = number
    description = "private subnet count"
    default = 2
}
variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
    description = "my cidr block"
}