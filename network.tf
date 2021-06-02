// Copyright (c) 2017, 2019, Oracle and/or its affiliates. All rights reserved.

resource "oci_core_virtual_network" "TF_VCN" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "TF_${var.clusterName}_VCN"
  dns_label      = "tfvcn"
}

resource "oci_core_subnet" "TF_Public_Subnet" {
  availability_domain     = "${data.oci_identity_availability_domain.ad.name}" 
  cidr_block          = "10.0.0.0/24"
  display_name        = "TF_${var.clusterName}_Public_Subnet"
  dns_label           = "tfpubsubnet"
  security_list_ids   = ["${oci_core_security_list.PUBLIC-SECURITY-LIST.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.TF_VCN.id}"
  route_table_id      = "${oci_core_route_table.TF_PUB_RT.id}"
}

resource "oci_core_subnet" "TF_GPU_Public_Subnet" {
  count = "1"
  availability_domain     = "${data.oci_identity_availability_domain.gpu_ad.name}"
  cidr_block          = "10.0.3.0/24"
  display_name        = "TF_${var.clusterName}_GPU_Public_Subnet"
  dns_label           = "tfgpusubnet"
  security_list_ids   = ["${oci_core_security_list.PUBLIC-GPU-SECURITY-LIST.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.TF_VCN.id}"
  route_table_id      = "${oci_core_route_table.TF_PUB_RT.id}"
}

resource "oci_core_subnet" "TF_FSS_Private_Subnet" {
  count = "1"
  availability_domain     = "${data.oci_identity_availability_domain.fss_ad.name}"
  cidr_block          = "10.0.2.0/24"
  display_name        = "TF_${var.clusterName}_FSS_Private_Subnet"
  dns_label           = "tffsssubnet"
  security_list_ids   = ["${oci_core_security_list.PRIVATE-SECURITY-LIST.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.TF_VCN.id}"
  route_table_id      = "${oci_core_route_table.TF_PRIV_RT.id}"
}

resource "oci_core_subnet" "TF_Private_Subnet" {
  availability_domain     = "${data.oci_identity_availability_domain.ad.name}"
  cidr_block          = "10.0.1.0/24"
  display_name        = "TF_${var.clusterName}_Private_Subnet"
  dns_label           = "tfprivsubnet"
  security_list_ids   = ["${oci_core_security_list.PRIVATE-SECURITY-LIST.id}"]
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_virtual_network.TF_VCN.id}"
  route_table_id      = "${oci_core_route_table.TF_PRIV_RT.id}"
}

resource "oci_core_internet_gateway" "TF_IG" {
  compartment_id = "${var.compartment_ocid}"
  display_name   = "TF_${var.clusterName}_IG"
  vcn_id         = "${oci_core_virtual_network.TF_VCN.id}"
}

resource "oci_core_nat_gateway" "TF_NATGW" {
        compartment_id = "${var.compartment_ocid}"
        vcn_id         = "${oci_core_virtual_network.TF_VCN.id}"
        display_name   = "TF_${var.clusterName}_NATGW"
}

resource "oci_core_route_table" "TF_PUB_RT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.TF_VCN.id}"
  display_name   = "TF_${var.clusterName}_Public_RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_internet_gateway.TF_IG.id}"
  }
}

resource "oci_core_route_table" "TF_PRIV_RT" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.TF_VCN.id}"
  display_name   = "TF_${var.clusterName}_Private_RouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${oci_core_nat_gateway.TF_NATGW.id}"
  }
}
resource "oci_core_security_list" "PRIVATE-SECURITY-LIST" {
        display_name    = "TF_${var.clusterName}_private-security-list"
        compartment_id  = "${var.compartment_ocid}"
        vcn_id          = "${oci_core_virtual_network.TF_VCN.id}"

        egress_security_rules {
                destination = "0.0.0.0/0"
                protocol    = "all"
        }

        ingress_security_rules {
                protocol        = "all"
                source          = "${oci_core_virtual_network.TF_VCN.cidr_block}"}
}   
resource "oci_core_security_list" "PUBLIC-SECURITY-LIST" {
        display_name    = "TF_${var.clusterName}_public-security-list"
        compartment_id  = "${var.compartment_ocid}"
        vcn_id          = "${oci_core_virtual_network.TF_VCN.id}"

        egress_security_rules {
                destination = "0.0.0.0/0"
                protocol    = "all"
        }

        ingress_security_rules {
                protocol        = "all"
                source          = "${oci_core_virtual_network.TF_VCN.cidr_block}"
        }   
        ingress_security_rules {
                protocol        = 6
                source          = "0.0.0.0/0"
                tcp_options {
                  "min" = "22"
                  "max" = "22"
                }
        }
}

resource "oci_core_security_list" "PUBLIC-GPU-SECURITY-LIST" {
        display_name    = "TF_${var.clusterName}_public-gpu-security-list"
        compartment_id  = "${var.compartment_ocid}"
        vcn_id          = "${oci_core_virtual_network.TF_VCN.id}"

        egress_security_rules {
                destination = "0.0.0.0/0"
                protocol    = "all"
        }

        ingress_security_rules {
                protocol        = "all"
                source          = "${oci_core_virtual_network.TF_VCN.cidr_block}"
        }   
        ingress_security_rules {
                protocol        = 6
                source          = "0.0.0.0/0"
                tcp_options {
                  "min" = "22"
                  "max" = "22"
                }
        }
}
