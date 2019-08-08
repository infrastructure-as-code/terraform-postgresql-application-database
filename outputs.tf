output "db-name" {
  value = "${local.db_name}"
}

# rw role
output "db-rw-user" {
  value = "${local.db_rw_user}"
}

output "db-rw-pass" {
  value = "${local.db_rw_pass}"
}

output "rw-psql" {
  value = "PGHOST=${local.db_host} PGPORT=${local.db_port} PGUSER=${local.db_rw_user} PGPASSWORD=${local.db_rw_pass} PGDATABASE=${local.db_name} psql"
}

output "rw-database-url" {
  value = "postgres://${local.db_rw_user}:${local.db_rw_pass}@${local.db_host}:${local.db_port}/${local.db_name}"
}

# ro role
output "db-ro-user" {
  value = "${local.db_ro_user}"
}

output "db-ro-pass" {
  value = "${local.db_ro_pass}"
}

output "ro-psql" {
  value = "PGHOST=${local.db_host} PGPORT=${local.db_port} PGUSER=${local.db_ro_user} PGPASSWORD=${local.db_ro_pass} PGDATABASE=${local.db_name} psql"
}

output "ro-database-url" {
  value = "postgres://${local.db_ro_user}:${local.db_ro_pass}@${local.db_host}:${local.db_port}/${local.db_name}"
}
