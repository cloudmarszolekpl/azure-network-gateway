variable "location" {
  type    = string
  default = "westeurope"
}
variable "prefix" {
  type    = string
  default = "dcazdemo"
}

variable "destination_ip_address" {
   type = string
   default = "178.218.234.221"
}

variable "destination_ip_range" {
   type = string 
   default = "192.168.0.160/27"
}

variable "local_shared_key" {
   type = string
   default = "1234567890aabb"
}

variable "environmenttag" {
   type= string
   default = null

}