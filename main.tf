################################################################################
# generate random credentials
resource "random_string" "rw_user" {
  length = 14
  special = false
  number = false
  upper = false
  lower = true
}

resource "random_string" "rw_pass" {
  length = 128
  special = false
  number = true
  upper = true
  lower = true
}

resource "random_string" "ro_user" {
  length = 14
  special = false
  number = false
  upper = false
  lower = true
}

resource "random_string" "ro_pass" {
  length = 128
  special = false
  number = true
  upper = true
  lower = true
}

locals {
  db_host = "${var.pg_host}"
  db_port = "${var.pg_port}"
  db_rw_user = "urw${random_string.rw_user.result}"
  db_rw_pass = "${random_string.rw_pass.result}"
  db_ro_user = "uro${random_string.ro_user.result}"
  db_ro_pass = "${random_string.ro_pass.result}"
  db_name = "${var.database_name}"
}

################################################################################
# The ro+rw roles that users inherit from
locals {
  db_rw_role = "${local.db_name}_rw_role"
  db_ro_role = "${local.db_name}_ro_role"
}

resource "postgresql_role" "rw" {
  name = "${local.db_rw_role}"
  login = false
  inherit = false
  skip_reassign_owned = true
}

resource "postgresql_role" "ro" {
  name = "${local.db_ro_role}"
  login = false
  inherit = false
  skip_reassign_owned = true
}

# the primary database user, who is also the owner of the
# database we just created.
resource "postgresql_role" "rw_user" {
  name = "${local.db_rw_user}"
  password = "${local.db_rw_pass}"
  login = true
  inherit = true
  skip_reassign_owned = true
  roles = [
    "${local.db_rw_role}",
    "${local.db_ro_role}",
  ]
  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
  ]
}

resource "postgresql_role" "ro_user" {
  name = "${local.db_ro_user}"
  password = "${local.db_ro_pass}"
  login = true
  inherit = true
  skip_reassign_owned = true
  roles = [
    "${local.db_ro_role}",
  ]
  depends_on = [
    "postgresql_role.ro",
  ]
}

################################################################################
# create the database
resource "postgresql_database" "db" {
  name = "${local.db_name}"
  template = "template1"
  lc_collate = "DEFAULT"
  encoding = "DEFAULT"
  lc_ctype = "DEFAULT"
  owner = "${local.db_rw_user}"
  allow_connections = true

  depends_on = [
    "postgresql_role.rw_user"
  ]
}

################################################################################
# set up permissions
# https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/
# https://dba.stackexchange.com/questions/17790/created-user-can-access-all-databases-in-postgresql-without-any-grants
# https://blog.dbrhino.com/locking-down-permissions-in-postgresql-and-redshift.html
resource "null_resource" "db_setup" {
  provisioner "local-exec" {

    command = <<END
psql --command="
ALTER SCHEMA public OWNER TO \"${local.db_rw_user}\";
REVOKE ALL ON DATABASE \"${local.db_name}\" FROM public;
"
END

    environment = {
      PGHOST = "${var.pg_host}"
      PGPORT = "${var.pg_port}"
      PGUSER = "${var.pg_user}"
      PGPASSWORD = "${var.pg_password}"
      PGDATABASE = "${local.db_name}"
    }
  }

  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
    "postgresql_role.rw_user",
    "postgresql_database.db",
  ]
}

resource "null_resource" "db_setup_defaults" {
  provisioner "local-exec" {

    command = <<END
psql --command="
REVOKE ALL ON DATABASE \"${local.db_name}\" FROM public;
REVOKE ALL ON SCHEMA public FROM public;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM public;

---- ro role
GRANT CONNECT ON DATABASE \"${local.db_name}\" TO \"${local.db_ro_role}\";
GRANT USAGE ON SCHEMA public TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES
GRANT SELECT ON TABLES TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES
GRANT SELECT ON SEQUENCES TO \"${local.db_ro_role}\";

--ALTER DEFAULT PRIVILEGES FOR ROLE \"${local.db_ro_role}\"
--GRANT EXECUTE ON FUNCTIONS TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES
GRANT USAGE ON TYPES TO \"${local.db_ro_role}\";

ALTER DEFAULT PRIVILEGES
GRANT USAGE ON SCHEMAS TO \"${local.db_ro_role}\";

---- rw role
GRANT CONNECT ON DATABASE \"${local.db_name}\" TO \"${local.db_rw_role}\";
GRANT ALL ON SCHEMA public TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TABLES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON SEQUENCES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON FUNCTIONS TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON TYPES TO \"${local.db_rw_role}\";

ALTER DEFAULT PRIVILEGES
GRANT ALL ON SCHEMAS TO \"${local.db_rw_role}\";
"
END

    environment = {
      PGHOST = "${local.db_host}"
      PGPORT = "${local.db_port}"
      PGUSER = "${local.db_rw_user}"
      PGPASSWORD = "${local.db_rw_pass}"
      PGDATABASE = "${local.db_name}"
    }
  }

  depends_on = [
    "postgresql_role.rw",
    "postgresql_role.ro",
    "postgresql_role.rw_user",
    "postgresql_database.db",
    "null_resource.db_setup",
  ]
}
