# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook

## Introduction
This runbook is designed to assist in the assessment of the OpenFOAM CFD Software in Oracle Cloud Infrastructure. It automatically downloads and configures OpenFOAM. 
OpenFOAM is the free, open source CFD software released and developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organisations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electromagnetics.

<img align="middle" src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/sim.gif" height="180" >
 

**Table of Contents**
- [Introduction](#introduction)
- [Architecture](#architecture)
  - [Baseline Infrastructure](#baseline-infrastructure)
  - [Optional Infrastructure](#optional-infrastructure)
- [Launch Cluster Network Steps](#launch-cluster-network-steps)
  - [Creation of Cluster Network through Marketplace](#creation-of-cluster-network-through-marketplace)
  - [Creation of Cluster Network through Manual Configuration](#creation-of-cluster-network-through-manual-configuration)
- [Access Your Cluster](#access-your-cluster)
- [Configure Visualization](#configure-visualization)
  - [Setting Up a VNC on your bastion](#setting-up-a-vnc-on-your-bastion)
  - [Add a GPU instance](#add-a-gpu-instance)
- [Accessing a VNC](#accessing-a-vnc)
- [Installing OpenFOAM](#installing-openfoam)
  - [Create a Machinefile](#create-a-machinefile)
  - [Install](#install)
  - [Compute Nodes](#compute-nodes)
- [Running OpenFOAM](#running-openfoam)


## Baseline Infrastructure
Cluster Networks are supported in the following regions.  In each case, we recommend using the baseline reference architecture and then adjusting it, as required, to meet your specific requirements: 
* VCN
  *	Public Subnet, Security List, Route Table
  *	Private Subnet, Security List, Route Table
  *	Internet Gateway
  *	NAT Gateway
*	Compute Nodes
  *	Bastion Host in a Public Subnet
  *	HPC Compute Nodes in Private Subnet

![](https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/arch.png "Architecture for Running StarCCM+ in OCI")

The above baseline infrastructure provides the following specifications:
-	Networking
    -	1 x 100 Gbps RDMA over converged ethernet (ROCE) v2
    -	Latency as low as 1.5 µs
-	HPC Compute Nodes (BM.HPC2.36)
    -	6.4 TB Local NVME SSD storage per node
    -	36 cores per node
    -	384 GB memory per node

## Optional Infrastructure
### Storage
On top of the NVME SSD storage that comes with the HPC shape, you can also attach block volumes at 32k IOPS per volume, backed by Oracle’s highest performance SLA.  If you are using our solutions to launch the infrastructure, an nfs-share is installed by default on the NVME SSD storage in /mnt.  You can also install your own parallel file system on top of either the NVME SSD storage or block storage, depending on your performance requirements.
### Visualizer Node
You can create a visualizer node, such as a GPU VM or BM machine, depending on your requirements. This visualizer node can be your bastion host or else it can be separate.  Depending on the security requirements for the workload, the visualizer node can be placed in the private or public subnet.


# Launch Cluster Network Steps 
There are many ways to launch an HPC Cluster Network, this solutions guide will cover two different methods:
*	Via Marketplace
*	Manually
Depending on your OS, you will want to go with a specific method. If the HPC Cluster Network marketplace image or our OCI HPC CN Terraform scripts are used, this is for Oracle Linux 7 only. If you want to use CentOS, Ubuntu or another OS, manual configuration is required.

## Creation of Cluster Network through Marketplace
Marketplace holds applications and images that can be deployed with our infrastructure.  For customers that want to use Oracle Linux, an HPC Cluster Network image is available and can be launched from directly within marketplace.
We suggest launching the [CFD Ready Cluster](https://cloudmarketplace.oracle.com/marketplace/en_US/listing/75645211) that will contain librairies needed for CFD.

1.	Within marketplace, select **Get App** at the top right.
2.	Select the OCI Region then click **Sign In**.
3.	Verify the version of the HPC Cluster image and then select the *Compartment* where the cluster will be launched. Accept the terms and conditions, then **Launch Stack**.
4.	Fill out the remaing details of the stack:
    1.	Select the desired **AD** for the compute shapes and the bastion.
    2.	Copy-paste your public **ssh key**
    3.	Type in the number of **Compute instances** for the cluster
    4. Leave Install OpenFOAM checked
    5. If you need more than 6TB of Shared disk space, check GlusterFS and select how many servers you would need. (6TB per server)
5.	Click **Create**.
6.	Navigate to *Terraform Actions* then click **Apply**. This will launch the CN provisioning.
7.	Wait until the job shows ‘Succeeded’ then navigate to **Outputs** to obtain the bastion and compute node private IP’s. 


## Creation of Cluster Network through Manual Configuration
Marketplace holds applications and images that can be deployed with our infrastructure.  For customers that want to use Oracle Linux, you can manually create a cluster network as follows:
1.	Select the OCI Region on the top right.
2.	In the main menu, select **Networking** and **Virtual Cloud Network**
3.	Click on Start VCN Wizard, and select **VCN with Internet Connectivity**
4.	Choose and name, the right compartment, and use 172.16.0.0/16 as **VCN CIDR**, 172.16.0.0/24 for Public Subnet and 172.16.1.0/24 for Private Subnet
5.	In the main menu, select **Compute**, **Instances**, then **Create Instance**
6.	Change the Image and select the **Oracle Image** tab, select **Oracle Linux 7 - HPC Cluster Networking Image**
7.	Select the **Availability Domain** in which you can spin up a BM.HPC2.36 instance
8.	Change the **shape** to BM.HPC2.36 under Bare Metal and Specialty
9.	Select the VCN and the public subnet you created. 
10.	Add a public key to connect to the instance. This key will be used on all compute instances. 
11.	Once the machine is up, click on the created instance. Under **More Actions**, select **Create Instance Configuration**. You can now **terminate** the instance under **More Actions**. 
12.	In the main menu, select **Compute**, then **Cluster Networks**
13.	Click **Create Cluster Network** and fill in all the options. Use the VCN, private subnet and instance configuration that you just created. Select the AD in which you can launch BM.HPC2.36 instances. 
14.	Launch the cluster network. 
15.	While it is loading, create another instance under **Main Menu**, **Compute** and **Instances**.
16.	Put it in the public subnet that was just created, using your public key and shape should be VM.Standard2.1 or similar. This will be the bastion that we will use to connect to the cluster. 
17.	SCP the key to the cluster on the bastion at /home/opc/.ssh/cluster_key and copy it also to /home/opc/.ssh/id_rsa
19.	Install the Provisioning Tool on the bastion via the following command:
```
sudo rpm -Uvh https://objectstorage.us-ashburn-1.oraclecloud.com/p/5R0v9HXBjdlN3H1m1LkoOQo1zVmq8MoSuz6vPb6-ztg/n/hpc/b/rpms/o/common/oci-hpc-provision-20190905-63.7.2.x86_64.rpm
```
18.	Navigate to **Compute** then **Instance Pools** in the Console and collect all the IP addresses for the cluster network pool. Or use this command on the bastion if you have nothing else running on your private subnet. 
```
for i in `nmap -sL Private_Subnet_CIDR | grep "Nmap scan report for" | grep ")" | awk '{print $6}'`;do echo ${i:1:-1} >> /tmp/ips; done
```
21.	Install the Provisioning Tool via the following command:
```
ips=`cat /tmp/ips`
/opt/oci-hpc/setup-tools/cluster-provision/hpc_provision_cluster_nodes.sh -p -i /home/opc/.ssh/id_rsa $ips
```

# Access your Cluster 
The public IP address of the bastion can be found on the lower left menu under Outputs. If you navigate to your instances in the main menu, you will also find your bastion instance as well as the public IP. 

The Private Key to access the machines can also be found there. Copy the text in a file on your machine, let's say/home/user/key:
```
chmod 600 /home/user/key 
ssh -i /home/user/key opc@ipaddress 
```

# Configure Visualization
HPC workloads often require visualization tools for scheduling, monitoring or analyzing the output of the simulations.  In these scenarios, it is often desired to create a GPU visualization node for optimal resolution and post processing. A GUI is not installed by default on OCI instances; however, one can be configured easily using VNC or X11 remote display protocol. The subsections below will walk through how to create a GPU visualization node in the public subnet using TurboVNC and OpenGL.

## Setting Up a VNC on your bastion
By default, the only access to the Oracle Linux machine is through SSH in a console mode. If you want to see the graphical interface, you will need to set up a VNC connection. The following script will work for the default user opc. The password for the vnc session is set as "HPC_oci1" but it can be edited in the next set of commands.
If you are not currently connected to the headnode via SSH, please do so as these commands need to be run on the headnode.
```
sudo yum -y groupinstall "Server with GUI"
sudo yum -y install tigervnc-server mesa-libGL
sudo systemctl set-default graphical.target
sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service
sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:1.service
sudo sed -ie '/^ExecStart=/a PIDFile=/home/opc/.vnc/%H%i.pid' /etc/systemd/system/vncserver@:1.service
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo "password" | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service
```

## Add a GPU instance.
The below steps are taken Using OpenGL to Enhance GPU Use cases on OCI - refer to the blog for more details. 
1.	Within the Console, navigate to Compute then Instances.
2.	Create a Compute Instance for the Visualization Node:
a.	Select the desired AD
b.	Select the desired GPU shape (either VM or BM)
c.	Specify a GPU-compatible Oracle Linux image
The latest Oracle Linux Image will automatically be GPU enabled. 
d.	Select the Cluster Network VCN and Public Subnet
e.	Copy-paste your public ssh key
f.	Click Create.
3.	Wait for the instance to provision then log into the instance via:   
```
ssh opc@<public ip> -i <private key> 
```
4.	Install X Window System, a display manager (GNOME/GDM), and a desktop environment (MATE):
```
sudo yum groupinstall "X Window System"
sudo yum install gdm
sudo yum groupinstall "MATE Desktop"
```
5.	Install VNC server and VirtualGL. Note that VirtualGL is an open source toolkit that lets any Linux or Unix console run OpenGL applications with full hardware acceleration.
```
sudo yum install https://downloads.sourceforge.net/project/virtualgl/2.6.3/VirtualGL-2.6.3.x86_64.rpm
sudo yum install https://downloads.sourceforge.net/project/turbovnc/2.2.4/turbovnc-2.2.4.x86_64.rpm
```
6.	Configure the X server to enable GPU sharing for virtual sessions. Run the following commands:
```
sudo nvidia-xconfig --use-display-device=none --busid="PCI:4:0:0"
```
7.	Configure the X server to enable GPU sharing for virtual sessions. Run the following commands:
```
sudo vglserver_config -config -s -f -t
```
8.	To avoid being locked out when the screen saver launches, set the local user password to something you can use later:
```
sudo passwd opc
```
9.	Change your VNC password to something you can use for logging on:
```
vncpasswd
```
10.	Restart the X Server:
```systemctl restart gdm
kill $(pgrep Xvnc)
vncserver
```
11.	Enable and Start GDM:
```
systemctl enable gdm --now
```
12.	Launch the VNC server:
```
/opt/TurboVNC/bin/vncserver -wm mate-session
```
13.	If you want to access the VNC server directly without SSH forwarding, ensure that your security list allows connections on port 5901/tcp.
    1.	In the Console, navigate to Networking then Virtual Cloud Networks.
    2.	Select Subnets and then the public subnet.
    3.	In the default security list, add an Ingress Rule with the following details:
        1.	Stateless: No
        2.	Source Type: CIDR
        3.	Source CIDR: 0.0.0.0/0
        4.	IP Protocol: TCP
        5.	Source Port Range: All
        6.	Destination Port Range: 5901

Note: The standard VNC port is 5900 plus a display number (for example, 5901 for :1, 5902 for :2)

14.	Allow access in local firewall settings, as follows:
```
sudo firewall-cmd --zone=public --permanent --add-port=5901/tcp
sudo firewall-cmd --reload
```
15.	Open TurboVNC or TigerVNC client. Enter the IP address connection as <public ip>:1

# Accessing a VNC
We will connect through an SSH tunnel to the instance. On your machine, connect using ssh
PORT below will be the number that results from 5900 + N. N is the display number, if the output for N was 1, PORT is 5901, if the output was 9, PORT is 5909
public_ip is the public IP address of the headnode, which is running the VNC server.
If you used the previous instructions, port will be 5901
```
ssh -L 5901:127.0.0.1:5901 opc@public_ip
```
You can now connect using any VNC viewer using localhost:N as VNC server and the password you set during the vnc installation.
You can chose a VNC client that you prefer or use this guide to install on your local machine:
*	[Windows - TigerVNC](https://github.com/TigerVNC/tigervnc/wiki/Setup-TigerVNC-server-%28Windows%29) 
*	[MacOS/Windows - RealVNC](https://www.realvnc.com/en/connect/download/)

# Installing OpenFOAM
***If you used the CFD Ready Cluster from marketplace, this step is not needed.***

This guide will show the different steps for the Oracle Linux 7.6 image available on Oracle Cloud Infrastructure.  




## Create a machinefile

If you used terraform to create the cluster, this step has been done already. 
OpenFOAM on the headnode does not automatically know which compute nodes are available. You can create a machinefile at `/mnt/nfs-share/install/machinefile.txt` with the private IP address of all the nodes along with the number of CPUs available. 

```
10.0.0.2 cpu=36
10.0.3.2 cpu=36
10.0.3.3 cpu=36
privateIP cpu=cores_available
...
```

## Install
You can download a precompiled version of OpenFOAM for Oracle Linux 7 [here](https://objectstorage.us-phoenix-1.oraclecloud.com/p/f48lM3aXtcEiCGJihz-sxpH808zie7VEbBHbihuZ2YI/n/hpc/b/HPC_APPS/o/openfoam7_OL77_RDMA.tar)
Just untar it and you are ready to go. 

If you want to install from sources, modify the path to the tarballs in the next commands. This example has the foundation OpenFOAM sources. OpenFOAM from ESI has also been tested. To share the installation between the different compute nodes, install on the network file system. This needs to be run from on of the compute nodes (example: hpc-node-1)

```
sudo yum groupinstall -y 'Development Tools'
sudo yum -y install devtoolset-8 gcc-c++ zlib-devel
sudo mkdir /mnt/nfs-share/install
sudo chown opc:opc /mnt/nfs-share/install 
cd /mnt/nfs-share/install
wget -O - http://dl.openfoam.org/source/7 | tar xvz
wget -O - http://dl.openfoam.org/third-party/7 | tar xvz
mv OpenFOAM-7-version-7 OpenFOAM-7
mv ThirdParty-7-version-7 ThirdParty-7
export PATH=/usr/mpi/gcc/openmpi-3.1.1rc1/bin/:/usr/lib64/qt5/bin/:$PATH
echo export PATH=/usr/mpi/gcc/openmpi-3.1.1rc1/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/mpi/gcc/openmpi-3.1.1rc1/lib64/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/nfs-share/install/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
source ~/.bashrc
cd /mnt/nfs-share/install/OpenFOAM-7
./Allwmake -j
```

## Compute Nodes
You just need to update the `~/.bashrc` on the compute nodes. 

```
echo export PATH=/usr/mpi/gcc/openmpi-3.1.1rc1/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/mpi/gcc/openmpi-3.1.1rc1/lib64/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/nfs/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
```


# Running OpenFOAM
Running OpenFOAM is not so straightforward if you are not familiar with the tool. Using this [script](https://objectstorage.us-phoenix-1.oraclecloud.com/p/JnZ4PqxqrYVqoX5_3ErNJcHU6--KlkPUXUEamJSo3R8/n/hpc/b/HPC_BENCHMARKS/o/motorbike_RDMA.tgz), you can do it very easily. This needs to be run on one of the compute nodes (Not the headnode) The script will be looking for a hostfile named hostfile in the current folder. See [Create a Machinefile](#create-a-machinefile)

In the following commands, replace `NP` by the number of total processes to run the model on. The maximum number is 36 * Number of nodes in your cluster

```
tar -xf motorbike_RDMA.tgz
./Allrun NP
```

If you are running your own model with your own script, here are the flags that you need to run on RDMA.  

```
-mca btl self -x UCX_TLS=rc,self,sm -x HCOLL_ENABLE_MCAST_ALL=0 -mca coll_hcoll_enable 0 -x UCX_IB_TRAFFIC_CLASS=105 -x UCX_IB_GID_INDEX=3 
```
Additionaly, instead of disabling hyper-threading, you can also force the MPI to pin it on the first 36 cores:
```
--cpu-set 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35
```
