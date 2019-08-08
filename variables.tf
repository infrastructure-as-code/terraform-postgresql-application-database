variable "database_name" {
  type = "string"
  description = "Name of database to be created"
}

variable "pg_host" {
  type = "string"
  description = "Postgresql host"
}

variable "pg_port" {
  type = "string"
  description = "Postgresql port"
}

variable "pg_user" {
  type = "string"
  description = "Postgresql user with createdb perms"
}

variable "pg_password" {
  type = "string"
  description = "Password for pg_user"
}
