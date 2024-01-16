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