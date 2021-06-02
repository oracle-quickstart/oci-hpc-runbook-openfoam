resource "null_resource" "remote-exec-HN" {
  depends_on = ["oci_core_instance.TF_HeadNodeInstance"]

  provisioner "file" {
    destination = "/home/opc/.ssh/id_rsa"
    source = "key.pem"

    connection {
    timeout = "15m"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    user = "opc"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/hn-start.sh"
    source = "hn-start.sh"

    connection {
    timeout = "15m"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    user = "opc"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/disable_ht.sh"
    source = "disable_ht.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/visualization.sh"
    source = "visualization.sh"

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
      timeout     = "15m"
      host        = "${oci_core_instance.TF_HeadNodeInstance.public_ip}"
      user        = "opc"
      private_key = "${tls_private_key.key.private_key_pem}"     
    }

    inline = [
    "sudo chmod 755 ~/hn-start.sh",
    "~/hn-start.sh ${oci_core_virtual_network.TF_VCN.cidr_block} ${var.nvme_nfs} ${var.file_system} ${var.block_nfs} ${var.mount_target_ip_address} \"${element(concat(oci_core_volume_attachment.TF_BlockAttach.*.iqn, list("")), 0)}\" ${element(concat(oci_core_volume_attachment.TF_BlockAttach.*.ipv4, list("")), 0)}:${element(concat(oci_core_volume_attachment.TF_BlockAttach.*.port, list("")), 0)} ${var.installer_drive} ${var.hyperThreading} ${var.nvme_local_size} | tee ~/hn-start.log",
    "mv ~/hn-start.log /mnt/${var.installer_drive}/logs/",
    "/mnt/${var.installer_drive}/scripts/visualization.sh ${var.headnode_vnc} ${var.VNCPassword} | tee /mnt/${var.installer_drive}/logs/hn-viz.log",
    ]
  }
} 

resource "null_resource" "remote-exec-CN" {
  count = "${var.computeNode_Count}"
  depends_on = ["null_resource.remote-exec-HN"]

  provisioner "file" {
    destination = "/home/opc/.ssh/id_rsa"
    source = "key.pem"

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
  }

  provisioner "file" {
    destination = "/home/opc/cn-start.sh"
    source = "cn-start.sh"

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
  }

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
    "sudo chmod 755 ~/cn-start.sh",
    "~/cn-start.sh ${oci_core_virtual_network.TF_VCN.cidr_block} ${oci_core_instance.TF_HeadNodeInstance.private_ip} ${var.nvme_nfs} ${var.file_system} ${var.mount_target_ip_address} ${var.block_nfs} ${var.installer_drive} ${var.hyperThreading} ${var.nvme_local_size}  | tee ~/cn-start${count.index}.log",
    "mv ~/cn-start${count.index}.log /mnt/${var.installer_drive}/logs/",
    ]
  }
}



resource "null_resource" "remote-exec-GPU" {
  count = "${var.GPUNode_Count}"
  depends_on = ["null_resource.remote-exec-HN"]

  provisioner "file" {
    destination = "/home/opc/.ssh/id_rsa"
    source = "key.pem"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }

  provisioner "file" {
    destination = "/home/opc/gpu-start.sh"
    source = "gpu-start.sh"

    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }
  }
  provisioner "remote-exec" {
    connection {
    timeout = "15m"
    user = "opc"
    host = "${oci_core_instance.TF_GPUInstance.*.public_ip[count.index]}"
    private_key = "${tls_private_key.key.private_key_pem}"
    agent = false
    }

    inline = [
    "sudo chmod 755 ~/gpu-start.sh",
    "~/gpu-start.sh ${oci_core_instance.TF_HeadNodeInstance.private_ip} ${var.nvme_nfs} ${var.file_system} ${var.mount_target_ip_address} ${var.block_nfs}| tee ~/gpu-start${count.index}.log",
    "mv ~/gpu-start${count.index}.log /mnt/${var.installer_drive}/logs/",
    "/mnt/${var.installer_drive}/scripts/visualization.sh ${var.gpu_vnc} ${var.VNCPassword} | tee /mnt/${var.installer_drive}/logs/gpu-viz.log",
    ]
  }
}