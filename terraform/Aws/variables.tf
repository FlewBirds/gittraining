variable "ports_web" {
    description = "Web services port numbers"
    type        = number
    default     = 80
}
variable "ports_tomcat" {
    description = "tomcat services port numbers"
    type        = number
    default     = 8080
}

variable "ami_us_east_2" {
    description = "ami id"
    type        = string
#    default     = ami-0568773882d492fc8
}
