## DATASOURCE
# Init Script Files

locals {
  php_script      = "~/install_php74.sh"
  moodle_script       = "~/install_moodle.sh"
  security_script = "~/configure_local_security.sh"
  create_moodle_db    = "~/create_moodle_db.sh"
  fault_domains_per_ad = 3
}

data "template_file" "install_php" {
  template = file("${path.module}/scripts/install_php74.sh")

  vars = {
    mysql_version         = var.mysql_version,
    user                  = var.vm_user
  }
}

data "template_file" "install_moodle" {
  template = file("${path.module}/scripts/install_moodle.sh")
}

data "template_file" "configure_local_security" {
  template = file("${path.module}/scripts/configure_local_security.sh")
}

data "template_file" "create_moodle_db" {
  template = file("${path.module}/scripts/create_moodle_db.sh")
  count    = var.nb_of_webserver
  vars = {
    admin_password  = var.admin_password
    admin_username  = var.admin_username
    moodle_password = var.moodle_password
    mds_ip          = var.mds_ip
    moodle_name     = var.moodle_name
    moodle_schema   = var.moodle_schema
    dedicated       = var.dedicated
    instancenb      = count.index+1
  }
}


resource "oci_core_instance" "Moodle" {
  count               = var.nb_of_webserver
  compartment_id      = var.compartment_ocid
  display_name        = "${var.label_prefix}${var.display_name}${count.index+1}"
  shape               = var.shape
  availability_domain = var.availability_domain
  defined_tags        = var.defined_tags

  dynamic "shape_config" {
    for_each = local.is_flexible_node_shape ? [1] : []
    content {
      memory_in_gbs = var.flex_shape_memory
      ocpus = var.flex_shape_ocpus
    }
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    display_name     = "${var.label_prefix}${var.display_name}${count.index+1}"
    assign_public_ip = var.assign_public_ip
    hostname_label   = "${var.display_name}${count.index+1}"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_keys
  }

  source_details {
    source_id   = var.image_id
    source_type = "image"
  }

  provisioner "file" {
    content     = data.template_file.install_php.rendered
    destination = local.php_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.install_moodle.rendered
    destination = local.moodle_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

  provisioner "file" {
    content     = data.template_file.configure_local_security.rendered
    destination = local.security_script

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }

 provisioner "file" {
    content     = data.template_file.create_moodle_db[count.index].rendered
    destination = local.create_moodle_db

    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }
  }


   provisioner "remote-exec" {
    connection  {
      type        = "ssh"
      host        = self.public_ip
      agent       = false
      timeout     = "5m"
      user        = var.vm_user
      private_key = var.ssh_private_key

    }

    inline = [
       "chmod +x ${local.php_script}",
       "sudo ${local.php_script}",
       "chmod +x ${local.moodle_script}",
       "sudo ${local.moodle_script}",
       "chmod +x ${local.security_script}",
       "sudo ${local.security_script}",
       "chmod +x ${local.create_moodle_db}",
       "sudo ${local.create_moodle_db}"
    ]

   }

  timeouts {
    create = "10m"

  }
}
