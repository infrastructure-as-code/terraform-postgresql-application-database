output "database_name" {
  value = "${local.db_name}"
}

output "rw_database_url" {
  value = "postgres://${local.db_rw_user}:${local.db_rw_pass}@${local.db_host}:${local.db_port}/${local.db_name}"
}

output "ro_database_url" {
  value = "postgres://${local.db_ro_user}:${local.db_ro_pass}@${local.db_host}:${local.db_port}/${local.db_name}"
}
