variable "appsec-agreement" {
    description = "Have you ever deployed a ckp management before? set to false if not"
    type = bool
    default = true
}
variable "appsec-name" {
    description = "Choose the name"
    type = string
}
variable "appsec-size" {
    description = "Choose the name"
    type = string
}
variable "admin-pwd" {
    description = "The password of the infinty gateway"
    sensitive = true
    type = string
}
variable "infinity-token" {
    description = "The token to connect to the Infinity Backend"
    sensitive = true
    type = string
}
