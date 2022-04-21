## Copyright (c) 2022 Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

resource "oci_mysql_mysql_db_system" "monitoring_mysql_db_system" {
    #Required
    count          = var.autoscaling_monitoring && var.autoscaling_mysql_service ? 1 : 0
    admin_password = var.admin_password
    admin_username = var.admin_username
    availability_domain = var.bastion_ad
    compartment_id = var.targetCompartment
    shape_name = var.monitoring_shape_name
    subnet_id = local.subnet_id
    display_name = "autoscaling_monitoring"
    is_highly_available = false
    data_storage_size_in_gb= "50"
    backup_policy {
        is_enabled = false
    }
    defined_tags                = { "${oci_identity_tag_namespace.ArchitectureCenterTagNamespace.name}.${oci_identity_tag.ArchitectureCenterTag.name}" = var.release }
}