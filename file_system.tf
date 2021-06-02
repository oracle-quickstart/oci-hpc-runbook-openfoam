resource "oci_file_storage_file_system" "ClusterFS" {
  count                       = "${var.file_system == "True" ? 1 : 0}"
  availability_domain         = "${data.oci_identity_availability_domain.fss_ad.name}" 
  compartment_id              = "${var.compartment_ocid}"
  }

resource "oci_file_storage_export" "ClusterFSExport" {
  count          = "${var.file_system == "True" ? 1 : 0}"
  export_set_id  = "${oci_file_storage_mount_target.ClusterFSMountTarget.0.export_set_id}"
  file_system_id = "${oci_file_storage_file_system.ClusterFS.id}"
  path           = "${var.ExportPathFS}"

  export_options {
    source = "10.0.0.0/16"
    access = "READ_WRITE"
    identity_squash = "NONE"
  }
}

resource "oci_file_storage_mount_target" "ClusterFSMountTarget" {
  count               = "${var.file_system == "True" ? 1 : 0}"
  availability_domain = "${data.oci_identity_availability_domain.fss_ad.name}" 
  compartment_id      = "${var.compartment_ocid}"
  subnet_id           = "${oci_core_subnet.TF_FSS_Private_Subnet.id}"
  display_name        = "fileserver_${var.clusterName}"
  hostname_label      = "fileserver"
  ip_address          = "${var.mount_target_ip_address}"
}
