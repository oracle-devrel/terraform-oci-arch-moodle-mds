## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "moodle_home_URL" {
  value = "http://${module.moodle.public_ip[0]}/"
}

output "moodle_db_user" {
  value = var.moodle_name
}

output "moodle_schema" {
  value = var.moodle_schema
}

output "moodle_db_password" {
  value = var.moodle_password
}

output "mds_instance_ip" {
  value = module.mds-instance.mysql_db_system.ip_address
  sensitive = true
}

output "ssh_private_key" {
  value = module.moodle.generated_ssh_private_key
  sensitive = true
}
