variable "database_name_prefix" {
  type = "string"
  description = "Name prefix of database to be created.  Actual database name will be returned in output."
}

variable "pg_host" {
  type = "string"
  description = "Postgresql host"
}

variable "pg_port" {
  type = "string"
  description = "Postgresql port"
  default = "5432"
}

variable "pg_user" {
  type = "string"
  description = "Postgresql user with createdb perms"
}

variable "pg_password" {
  type = "string"
  description = "Password for pg_user"
}
