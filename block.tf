resource "oci_core_volume" "TF_BV" {
    count = "${var.block_nfs == "True" ? 1 : 0}"
    availability_domain = "${data.oci_identity_availability_domain.ad.name}"
    compartment_id = "${var.compartment_ocid}"
    size_in_gbs = "${var.size_block_volume}"
}

resource "oci_core_volume_attachment" "TF_BlockAttach" {
  count           = "${var.block_nfs == "True" ? 1 : 0}"
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.TF_HeadNodeInstance.id}"
  volume_id       = "${oci_core_volume.TF_BV.id}"
  device          = "${var.devicePath}"
}
