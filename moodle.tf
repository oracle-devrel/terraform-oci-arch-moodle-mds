## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

module "moodle" {
  source                = "./modules/moodle"
  availability_domain   = var.availability_domain_name == "" ? data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain_number]["name"] : var.availability_domain_name
  compartment_ocid      = var.compartment_ocid
  image_id              = lookup(data.oci_core_images.InstanceImageOCID.images[0], "id")
  shape                 = var.node_shape
  label_prefix          = var.label_prefix
  subnet_id             = oci_core_subnet.moodle_public_subnet.id
  ssh_authorized_keys   = local.ssh_key
  ssh_private_key       = local.ssh_private_key
  mds_ip                = module.mds-instance.mysql_db_system.ip_address
  admin_password        = var.admin_password
  admin_username        = var.admin_username
  moodle_schema         = var.moodle_schema
  moodle_name           = var.moodle_name
  moodle_password       = var.moodle_password
  moodle_admin_user     = var.moodle_admin_user
  moodle_admin_password = var.moodle_admin_password
  moodle_admin_email    = var.moodle_admin_email
  moodle_site_fullname  = var.moodle_site_fullname
  moodle_site_shortname = var.moodle_site_shortname
  display_name          = var.moodle_instance_name
  flex_shape_ocpus      = var.node_flex_shape_ocpus
  flex_shape_memory     = var.node_flex_shape_memory
  defined_tags          = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}
