variable "db_instance_type" {
  default     = "db.t2.micro"
  description = "give the database instance_type"
}

variable "db_storage_size" {
  default     = 5
  description = "give the database instance allocated_storage in gbs"
}

variable "database_engine" {
  default     = "mysql"
  description = "give the database instance_engine "
}

variable "database_engine_ver" {
  default     = "8.0.27"
  description = "give the database instance engine engine version "
}

variable "database_user_name" {
  default     = "asf"
  description = "give the database username"
}

variable "database_user_password" {
  default     = "afdadfada"
  description = "give the database password"
}