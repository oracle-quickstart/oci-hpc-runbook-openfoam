variable "ad" {
    default = "1"
}
variable "gpu_ad" {
    default = "3"
}
variable "fss_ad" {
    default = "2"
}
variable "computeNode_Count" {
    default = "4"
}
variable "GPUNode_Count" {
    default = "1"
}
variable "VNCPassword" {
    default = "HPC_oci1"
}
variable "region" { }
variable "tenancy_ocid" { }
variable "compartment_ocid" { }
#variable "user_ocid" { }
#variable "fingerprint" { }
#variable "private_key_path" {  }

variable "compute_shape" {
    default = "BM.HPC2.36"
}
variable "headnode_shape" {
    default = "BM.HPC2.36"
}
variable "gpu_shape" { 
    default = "VM.GPU2.1"
}

# Possible values are none, vnc or x11vnc
# If x11vnc is selected and NVIDIA drivers are not available, vnc will be used.
variable "headnode_vnc" { 
    default = "none"
}

# Possible values are none, vnc or x11vnc
# If x11vnc is selected and NVIDIA drivers are not available, vnc will be used.
variable "gpu_vnc" { 
    default = "x11vnc"
}

# Install FSS, value are 0 or 1
variable "file_system" {
  default = "False"
}

# Install NVME, value are 0 or 1
variable "nvme_nfs" {
  default = "True"
}

# Install Block NFS, value are 0 or 1
variable "block_nfs" {
  default = "False"
}

# Specify the drive of the installation, 
#  Possible values are nvme, block or fss
variable "installer_drive" {
  default = "nvme"
}

variable "model_drive" {
  default = "nvme"
}

variable "ExportPathFS" {
  default = "/sharedFS"
}

variable "mount_target_ip_address" {
  default = "10.0.2.4"
}

# Size in GB
variable "size_block_volume" {
  default = "500"
}

variable "devicePath" {
  default = "/dev/oracleoci/oraclevdb"
}

variable "hyperThreading" {
  default = "off"
}

variable "clusterName" {
  default = "openfoam"
}

variable "nvme_local_size" {
  default = "0"
}
variable "openfoam_source_url" { 
    default = ""
}

variable "thirdparty_source_url" { 
    default = ""
}

variable "model_url" { 
    default = ""
}

variable "openfoam_compiled_url" { 
    default = "https://objectstorage.us-phoenix-1.oraclecloud.com/p/vrm58o1o_tsFHC-p9_-y_6MiKudC3_1sRYdx29fuNoQ/n/hpc/b/HPC_APPS/o/OpenFOAM7_OL7.tar"
}
variable "user_ocid" { }
variable "fingerprint" { }
variable "private_key_path" {  }