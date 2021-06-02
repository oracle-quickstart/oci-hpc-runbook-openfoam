
resource "null_resource" "remote-exec-HN_APP_Specific" {
  depends_on = ["oci_core_instance.TF_HeadNodeInstance","null_resource.remote-exec-HN",]

  provisioner "file" {
    destination = "/mnt/${var.installer_drive}/scripts/hn-start-app.sh"
    source = "hn-start-app.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/mnt/${var.installer_drive}/scripts/cn-start-app.sh"
    source = "cn-start-app.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }
  provisioner "file" {
    destination = "/mnt/${var.installer_drive}/scripts/gpu-start-app.sh"
    source = "gpu-start-app.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }
  provisioner "file" {
    destination = "/mnt/${var.installer_drive}/scripts/visualization-app.sh"
    source = "visualization-app.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "remote-exec" {
    connection {
      agent       = false
      timeout     = "20m"
      host        = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
      user        = "opc"
      private_key = "${tls_private_key.key.private_key_pem}"
    }

    inline = [
    "chmod 755 /mnt/${var.installer_drive}/scripts/hn-start-app.sh", 
    "chmod 755 /mnt/${var.installer_drive}/scripts/cn-start-app.sh", 
    "chmod 755 /mnt/${var.installer_drive}/scripts/gpu-start-app.sh", 
    "chmod 755 /mnt/${var.installer_drive}/scripts/visualization-app.sh", 
    "/mnt/${var.installer_drive}/scripts/hn-start-app.sh ${oci_core_instance.TF_HeadNodeInstance.private_ip} ${var.installer_drive} ${var.model_drive} \"${var.model_url}\" \"${var.openfoam_source_url}\" \"${var.thirdparty_source_url}\" \"${var.openfoam_compiled_url}\" | tee /mnt/${var.installer_drive}/logs/hn-start-app.log",
    "/mnt/${var.installer_drive}/scripts/visualization-app.sh ${var.installer_drive} ${var.headnode_vnc} | tee /mnt/${var.installer_drive}/logs/hn-viz-app.log",
    ]
  }
}


resource "null_resource" "remote-exec-CN_APP_Specific" {
  count = "${var.computeNode_Count}"
  depends_on = ["null_resource.remote-exec-HN_APP_Specific","null_resource.remote-exec-CN",]
  
  provisioner "remote-exec" {
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false

    bastion_host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    bastion_user = "opc"
    bastion_private_key = "${tls_private_key.key.private_key_pem}"
    }

    inline = [
    "/mnt/${var.installer_drive}/scripts/cn-start-app.sh ${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]} ${var.installer_drive} | tee /mnt/${var.installer_drive}/logs/cn-start-app${count.index}.log",
    ]
  }

  provisioner "remote-exec" {
    when = "destroy"
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }

    inline = [
    "sed '/${oci_core_instance.TF_ComputeInstance.*.private_ip[count.index]}/d' /mnt/${var.installer_drive}/machinelist.txt >> /mnt/${var.installer_drive}/new_machinelist${count.index}.txt",
    "mv /mnt/${var.installer_drive}/new_machinelist${count.index}.txt /mnt/${var.installer_drive}/machinelist.txt",
    ]
  }

}

resource "null_resource" "remote-exec-GPU_Application_Specific" {
  depends_on = ["null_resource.remote-exec-GPU",]
  count = "${var.GPUNode_Count}"
  
  provisioner "remote-exec" {
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }

    inline = [
    "mnt/${var.installer_drive}/scripts/gpu-start-app.sh ${var.installer_drive} | tee /mnt/${var.installer_drive}/logs/gpu-start-app${count.index}.log",
    "/mnt/${var.installer_drive}/scripts/visualization-app.sh ${var.installer_drive} ${var.gpu_vnc} | tee /mnt/${var.installer_drive}/logs/gpu-viz-app.log",
    ]
  }
}



