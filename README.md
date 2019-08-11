# PostgreSQL Application Database Terraform Module

## Introduction

PostgreSQL has a robust set of [user roles and permissions](https://www.postgresql.org/docs/11/user-manag.html) that may take some effort to implement, and may often to overlooked by developers focused on building their applications.  This module aims to simplify the process of managing database users & permissions so that developers can be assured their data is secured from other users on a [multi-tenant](https://en.wikipedia.org/wiki/Multitenancy) database server instance, letting them focus on their applications instead.


## Details

[Heroku Postgres](https://www.heroku.com/postgres) was a huge inspiration for the author, and this module was designed to emulate the databases created by the _Hobby Dev_ and _Hobby Basic_ plans where:

1. Databases created will have all permissions revoked so that no users can use or connect to it unless permissions are explicitly granted.
1. Two roles--`<db_name>_rw_role` and `<db_name>_ro_role`-- are created with read-write and read-only permsssions respectively.
1. A user with read-write permissions to the database is created, along with a user with read-only permissions, and inherit their permissions from the respective roles.

This module is probably useful only to those who are running their own PostgreSQL server instance (e.g. AWS RDS, on-premise, etc), while others may prefer the [terraform-heroku-cloud-database](http://github.com/infrastructure-as-code/terraform-heroku-cloud-database) module instead.


## Pre-requisites

1. Terraform 0.12.x.  (May work work 0.11.x.)
1. `psql` client on the host that runs the module (needed to work around a missing feature [#46](https://github.com/terraform-providers/terraform-provider-postgresql/issues/46) in the Terraform PostgreSQL provider)
1. A [PostgreSQL server instance](http://www.postgresqltutorial.com/postgresql-server-and-database-objects/) (e.g. AWS RDS, or a vanilla PostgreSQL server), and an user with permissions to create databases and manage users.


## Usage

```
provider "postgresql" {
  host = "ec2-50-16-225-96.compute-1.amazonaws.com"
  port = "5432"
  database = "postgres"
  username = "postgres"
  password = "p0stgr3s"
  superuser = false
}

module "tenant_database" {
  source = "github.com/infrastructure-as-code/terraform-postgresql-database"
  pg_host = "ec2-50-16-225-96.compute-1.amazonaws.com"
  pg_port = "5432"
  pg_user = "postgres"
  pg_password = "p0stgr3s"
  database_name = "foo"
}
```

The database credentials have to be passed to both the [PostgreSQL provider](https://www.terraform.io/docs/providers/postgresql/index.html) as well as the module itself because there is no way to switch users/databases at the Terraform resource level.  There is an issue ([#46](https://github.com/terraform-providers/terraform-provider-postgresql/issues/46)) open with the provider authors for over a year now.


### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| database\_name | The name of the new database to create | string | - | yes |
| pg\_host | Hostname of Postgresql server | string | - | yes |
| pg\_port | TCP port that the Postgresql is listening on | string | `5432` | yes |
| pg\_user | Username of Postgresql user who must have createdb permissions | string | - | yes |
| pg\_password | Password of Postgresql user who has createdb permssions | string | - | yes |


### Outputs

| Name | Description |
|------|-------------|
| database\_name | Name of database created |
| rw\_database\_url | Database URL for read-write user |
| ro\_database\_url | Database URL for read-only user |


## Use Cases

1. Creating RDS databases, even when automated, adds minutes to a deployment (e.g. with AWS Elastic Beanstalk), and hurts developer velocity.  Instead of creating an RDS instance for each developer/application, one can use this module to create databases on a shared RDS instance and save time.
1. The overheads of running a PostgreSQL instance may add up, and isn't necessarily a good use of resources even with tiny instances (like `db.t2.micro` on RDS), so sharing non-production instances allows low-utilization resources to be used more efficiently.
1. This module creates a read-only user and a read-write user for each database, and locks down the permissions


## License

MIT-Licensed.  Please see [LICENSE](LICENSE) for details.


## References

1. [Managing PostgreSQL users and roles](https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/)
1. [Heroku Postgres Credentials](https://devcenter.heroku.com/articles/heroku-postgresql-credentials)
1. [Created user can access all databases in PostgreSQL without any grants](https://dba.stackexchange.com/questions/17790/created-user-can-access-all-databases-in-postgresql-without-any-grants)
1. [Locking Down Permissions in PostgreSQL and Redshift](https://blog.dbrhino.com/locking-down-permissions-in-postgresql-and-redshift.html)
