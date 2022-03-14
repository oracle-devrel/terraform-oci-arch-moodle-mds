output "id" {
  value = oci_core_instance.Moodle.*.id
}

output "public_ip" {
  value = join(", ", oci_core_instance.Moodle.*.public_ip)
}

output "moodle_user_name" {
  value = var.moodle_name
}

output "moodle_schema_name" {
  value = var.moodle_schema
}

output "moodle_host_name" {
  value = oci_core_instance.Moodle.*.display_name
}
