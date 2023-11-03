variable "Non-prod-vpc" {
  default     = "10.0.0.0/16"
  description = "enter the production vpc"
}


variable "Non-prod-subnet-1" {
  default     = "10.0.0.0/22"
  description = "enter the production subnet"
}
variable "Non-prod-subnet-2" {
  default     = "10.0.4.0/22"
  description = "enter the production subnet"
}
variable "Non-prod-subnet-3" {
  default     = "10.0.8.0/22"
  description = "enter the production subnet"
}
variable "Non-prod-subnet-4" {
  default     = "10.0.12.0/22"
  description = "enter the production subnet"
}
variable "Non-prod-subnet-5" {
  default     = "10.0.16.0/22"
  description = "enter the production subnet"
}
variable "Non-prod-subnet-6" {
  default     = "10.0.20.0/22"
  description = "enter the production subnet"
}


// AZ

variable "availability-zone-1" {
  type    = string
  default = "eu-central-1a"
}
variable "availability-zone-2" {
  type    = string
  default = "eu-central-1b"
}
variable "availability-zone-3" {
  type    = string
  default = "eu-central-1c"
}