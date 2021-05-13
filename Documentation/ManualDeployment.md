# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook


# Deployment via web console

**Table of Contents**

- [Deployment via web console](#deployment-via-web-console)
  - [Log In](#log-in)
  - [Virtual Cloud Network](#virtual-cloud-network)
    - [Subnets](#subnets)
    - [NAT Gateway](#nat-gateway)
    - [Security List](#security-list)
    - [Route Table](#route-table)
    - [Subnet](#subnet)
  - [Compute Instance](#compute-instance)
  - [Mounting a drive](#mounting-a-drive)
  - [Creating a Network File System](#creating-a-network-file-system)
    - [Headnode](#headnode)
    - [Compute Nodes](#compute-nodes)
  - [Allow communication between machines](#allow-communication-between-machines)
  - [Adding a GPU Node for pre/post processing](#adding-a-gpu-node-for-prepost-processing)
  - [Setting up VNC](#setting-up-vnc)
  - [Setting up X11VNC](#setting-up-x11vnc)
  - [Accessing a VNC](#accessing-a-vnc)
- [Installation](#installation)
  - [Connecting all compute node](#connecting-all-compute-node)
  - [Create a machinefile](#create-a-machinefile)
  - [Disable Hyperthreading](#disable-hyperthreading)
  - [OpenFOAM](#openfoam)
  - [Paraview](#paraview)

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Virtual Cloud Network
Before creating an instance, we need to configure a Virtual Cloud Network. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

On the next page, select the following: 
* Name of your VCN
* Compartment of your VCN
* Choose "CREATE VIRTUAL CLOUD NETWORK PLUS RELATED RESOURCES"

Scroll all the way down and <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

Close the next window. 

### Subnets
If you are using one compute node, the subnet was created during the VNC creation. If you want to create a cluster, we will generate a private subnet for the compute nodes, accessible only from the headnode.

Before we generate a private subnet, we will define a security rule to be able to access it from the headnode. We would also like to download packages on our compute nodes, we will create a NAT gateway to be able to access online repositories to update the machine. 

### NAT Gateway
You have just created a VCN, click on the name.
In the ressource menu on the left side of the page, select NAT Gateways.

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/resources_menu.png" height="200">

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">

Choose a name (Ex:OPENFOAM_NAT) and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">


### Security List
In the ressource menu on the left side of the page, select Security Lists.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

Select a name like OPENFOAM_Private_SecList

Add an Ingress Rule with CIDR 10.0.0.0/16 and select All Protocols

Add an Egress Rule with CIDR 0.0.0.0/0 and select All Protocols

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

To allow the creation of a Network File System, we also need to add sa couple of ingress rules for the Default Security List for OPENFOAM_VCN. Click on "Default Security List for OPENFOAM_VCN" in the list. 

Add one ingress rules for all ports on TCP for NFS. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 10.0.0.0/16
* IP PROTOCOL: TCP
* Source Port Range: All
* Destination Port Range: All

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

Add another ingress rule for UDP for NFS:

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 10.0.0.0/16
* IP PROTOCOL: UDP
* Source Port Range: All
* Destination Port Range:111,2049

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 


### Route Table
In the ressource menu on the left side of the page, select Route Tables.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

Change the name to OPENFOAM_Private_RT

Click + Additional Route Rule and select the settings:

* TARGET TYPE : NAT Gateway
* DESTINATION CIDR BLOCK : 0.0.0.0/0
* TARGET NAT GATEWAY : OPENFOAM_NAT

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

### Subnet
In the ressource menu on the left side of the page, select Subnets.
Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

Choose the following settings:

* NAME : OPENFOAM_Private_Subnet
* TYPE: "REGIONAL"
* CIDR BLOCK: 10.0.3.0/24
* ROUTE TABLE: OPENFOAM_Private_RT
* SUBNET ACCESS: "PRIVATE SUBNET"
* SECURITY LIST: OPENFOAM_Private_SecList

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

## Compute Instance
Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Instances.png" height="300">

On the next page, select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="25">

On the next page, select the following:
* Name of your instance
* Availibility Domain: Each region has multiple availability domain. Some instance shapes are only available in certain AD.
* Change the image source to Oracle Linux 7.6
* Instance Type: Select Bare metal
* Instance Shape: 
  * BM.HPC2.36
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* SSH key: Attach your public key file. [For more information](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).
* Virtual Cloud Network: Select the network that you have previsouly created. In the case of a cluster: Select the public subnet for the Headnode and the Private Subnet for the compute nodes.

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="20">

After a few minutes, the instances will turn green meaning it is up and running. You can now SSH into it. After clicking on the name of the instance, you will find the public IP. You can now connect using `ssh opc@xx.xx.xx.xx` from the machine using the key that was provided during the creation. 

For a compute node to be able to access the NAT Gateway, select the compute node and in the Resources menu on the left, click on Attached VNICs. 

Hover over the three dots at the end of the line and select "Edit VNIC"

Uncheck "Skip Source/Destination Check"

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/updateVNIC.png" height="20">

Restart This section for each compute instance. Before you do that, we will create a ssh key specific for the cluster to allow all machines to talk to each other using ssh. Log on to the headnode you created and run the command `ssh-keygen`. Do not change the file location (/home/opc/.ssh/id_rsa) and hit enter when asked about a passphrase (twice). Or run this command:

```cat /dev/zero | ssh-keygen -q -N ""```

Add the content of id_rsa.pub into the file /home/opc/.ssh/authorized_keys. You will also use the content of id_rsa.pub as the public key when creating your compute nodes. 

```cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys```

## Mounting a drive

HPC machines have local NVMe storage but it is not mounted by default. Let's take care of that! 

After logging in using ssh, run the command `lsblk`. 
The drive should be listed with the NAME on the left (Probably nvme0n1, if it is different, change it in the next commands)

The headnode will have the shared drive with the installation and the model. This will be shared between all the different compute nodes. Each compute node will also mount the drive to be running locally on a NVMe drive. In this example the share directory will be 500 GB but feel free to change that.  

If your headnode is also a compute node, you can partition the drive. 

Make sure gdisk is installed : ` sudo yum -y install gdisk `
Let's use it: 
```
sudo gdisk /dev/nvme0n1
> n      # Create new partition
> 1      # Partition Number
>        # Default start of the partition
> +500G  # Size of the shared partition
> 8300   # Type = Linux File System
> n      # Create new partition
> 2      # Partition Number
>        # Default start of the partition
>        # Default end of the partition, to fill the whole drive
> 8300   # Type = Linux File System
> w      # Write to file
> Y      # Accept Changes
```

Format the drive on the compute node:
```
sudo mkfs -t ext4 /dev/nvme0n1
```

Format the partitions on the headnode node:
```
sudo mkfs -t ext4 /dev/nvme0n1p1
sudo mkfs -t ext4 /dev/nvme0n1p2
```

Create a directory and mount the drive to it. For the headnode, select `/mnt/share` as the mount directory for the 500G partition and `/mnt/local` for the larger one. For compute node, select `/mnt/local` as the mount directory of the whole drive.

Compute Node:
```
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1 /mnt/local
sudo chmod 777 /mnt/local
```

Head Node (local and share):
```
sudo mkdir /mnt/share
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1p1 /mnt/share
sudo mount /dev/nvme0n1p2 /mnt/local
sudo chmod 777 /mnt/share
sudo chmod 777 /mnt/local
```

Head Node (share):
```
sudo mkdir /mnt/share
sudo mount /dev/nvme0n1 /mnt/share
sudo chmod 777 /mnt/share
```

## Creating a Network File System

### Headnode

Since the headnode is in a public subnet, we will keep the firewall up and add an exception through. 
```
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload
```
We will also activate the nfs-server:

```
sudo yum -y install nfs-utils
sudo systemctl enable nfs-server.service
sudo systemctl start nfs-server.service
```

Edit the file /etc/exports with vim or your favorite text editor. `sudo vi /etc/exports` and add the line `/mnt/share   10.0.0.0/16(rw)`

To activate those changes:

```
sudo exportfs -a
```

### Compute Nodes

On the compute nodes, since they are in a private subnet with security list restricting access, we can disable it altogether. We will also install the nfs-utils tools and mount the drive. You will need to grab the private IP address of the headnode. You can find it in the instance details in the webbrowser where you created the instances, or find it by running the command `ifconfig` on the headnode. It will probably be something like 10.0.0.2, 10.0.1.2 or 10.0.2.2 depending on the CIDR block of the public subnet. 

```
sudo systemctl stop firewalld
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo mount 10.0.0.2:/mnt/share /mnt/share
```


## Allow communication between machines

After creating the headnode, you generated a key for the cluster using `ssh.keygen`. We will need to send the file `~/.ssh/id_rsa` on all compute nodes. On the headnode, run ```scp /home/opc/.ssh/id_rsa 10.0.3.2:/home/opc/.ssh``` and run it for each compute node by changing the IP address. 

## Adding a GPU Node for pre/post processing

Postprocessing OpenFOAM is typically done with Paraview and can take advantage of the power of GPUs. We can turn a GPU node on demand when the simulation is done. 

Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Instances.png" height="300">

On the next page, select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="25">

On the next page, select the following:
* Name of your instance
* Availibility Domain: Each region has multiple availability domain. Some instance shapes are only available in certain AD.
* Change the image source to Oracle Linux 7.6
* Instance Type: Select Bare metal for BM.GPU2.2 or Virtual Machine for VM.GPU2.1
* Instance Shape: 
  * BM.GPU2.2
  * VM.GPU2.1
  * BM.GPU3.8
  * VM.GPU3.*
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* SSH key: Attach your public key file. [For more information](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).
* Virtual Cloud Network: Select the network that you have previsouly created. In the case of a cluster: Select the public subnet.

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="20">

After a few minutes, the instances will turn green meaning it is up and running. You can now SSH into it. After clicking on the name of the instance, you will find the public IP. You can now connect using `ssh opc@xx.xx.xx.xx` from the machine using the key that was provided during the creation. 

Use SSH to remote login to the machine and mount the share drive as show before: 

```
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo mount 10.0.0.2:/mnt/share /mnt/share
```
## Setting up VNC
If you used terraform to create the cluster, this step has been done already for the GPU instance.

By default, the only access to the Oracle Linux machine is through SSH in a console mode. If you want to see the graphical interface, you will need to set up a VNC connection. The following script will work for the default user opc. The password for the vnc session is set as "password" but it can be edited in the next commands.

```
sudo yum -y groupinstall 'Server with GUI'
sudo yum -y install tigervnc-server mesa-libGL
sudo systemctl set-default graphical.target
sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:0.service
sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:0.service
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo "HPC_oci1" | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
sudo systemctl start vncserver@:0.service
sudo systemctl enable vncserver@:0.service
```


## Setting up X11VNC
If you used terraform to create the cluster, this step has been done already for the GPU instance.

By default, the only access to the Oracle Linux machine is through SSH in a console mode. If you want to see the graphical interface, you will need to set up a VNC connection. The following script will work for the default user opc. The password for the vnc session is set as "password" but it can be edited in the next commands. 

```
sudo yum -y groupinstall "Server with GUI"
sudo yum -y install x11vnc mesa-libGL
sudo nvidia-xconfig --enable-all-gpus --separate-x-screens
sudo systemctl isolate multi-user.target
sudo systemctl isolate graphical.target
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo "HPC_oci1" | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
sudo x11vnc -rfbauth ~/.vnc/passwd  -auth /var/lib/gdm/:0.Xauth -display :0 -forever -bg -repeat -nowf -o ~/.vnc/x11vnc.log
sudo x11vnc -rfbauth ~/.vnc/passwd  -auth /var/lib/gdm/:0.Xauth -display :0 -forever -bg -repeat -nowf -o ~/.vnc/x11vnc.log
```

During the login, you will need to use the opc password. It has not been set by default. You can choose one with 
* 1 Uppercase Letter
* 1 Lowercase Letter
* 1 Number
* 1 Symbol
* Not a dictionary word. 

Set it with the following commands. If the terraform or ORM scripts were used, the default password is `HPC_oci1`.

```
sudo passwd opc 
```

## Accessing a VNC
We will connect through an SSH tunnel to the instance. On your machine, connect using ssh 

```
ssh -L 5902:127.0.0.1:5900 opc@public_ip
```

You can now connect using any VNC viewer using localhost:2 as VNC server and the password you set during the vnc installation. 

If you would rather connect without a SSH tunnel. You will need to open ports 5900 and 5901 on the Linux machine both in the firewall and in the security list. 

```
sudo firewall-offline-cmd --zone=public --add-port=5900-5901/tcp
```

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

Select the VCN that you created. Select the Subnet in which the machine reside, probably your public subnet. Select the security list. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 0.0.0.0/0
* IP PROTOCOL: TCP
* Source Port Range: All
* Destination Port Range: 5900-5901

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

Now you should be able to VNC to the address: ip.add.re.ss:5900

Once you accessed your VNC session, you should go into Applications, then System Tools Then Settings.  

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/CentOSSeetings.jpg" height="100"> 

In the power options, set the Blank screen timeout to "Never". If you do get locked out of your user session, you can ssh to the instance and set a password for the opc user.

```
sudo passwd opc
```

# Installation
This guide will show the different steps for the Oracle Linux 7.6 image available on Oracle Cloud Infrastructure.  

## Connecting all compute node

Each compute node needs to be able to talk to all the compute nodes. SSH communication works but most applications have issues if all the hosts are not in the known host file. To disable the know host check for nodes with address in the VCN, you can deactivate with the following commands. You may need to modify it slightly if your have different addresses in your subnets. 

```
for i in 0 1 2 3
do
    echo Host 10.0.$i.* | sudo tee -a ~/.ssh/config
    echo "    StrictHostKeyChecking no" | sudo tee -a ~/.ssh/config
done
```

## Create a machinefile

If you used terraform to create the cluster, this step has been done already. 
OpenFOAM on the headnode does not automatically know which compute nodes are available. You can create a machinefile at `/mnt/share/install/machinefile.txt` with the private IP address of all the nodes along with the number of CPUs available. 

```
10.0.0.2 cpu=36
10.0.3.2 cpu=36
10.0.3.3 cpu=36
privateIP cpu=cores_available
...
```

## Disable Hyperthreading

If you used terraform to create the cluster, this step has been done already. 
Siemens recommmend to turn off hyperthreading on your compute nodes to get better performances. This means that you have only one thread per CPU. By default, on HPC shapes, you have 36 CPU with 2 threads. You can turn it off like this:
```
for i in {36..71}; do
   echo "Disabling logical HT core $i."
   echo 0 | sudo tee /sys/devices/system/cpu/cpu${i}/online;
done
```

## OpenFOAM

### HeadNode
If you have the correct binaries of your OpenFOAM version. Just untar it and you are ready to go. 

If you want to install from sources, modify the path to the tarballs in the next commands. This example has the foundation OpenFOAM sources. OpenFOAM from ESI has also been tested. To share the installation between the different compute nodes, install on the network file system.   

```
sudo yum groupinstall -y 'Development Tools'
sudo yum -y install devtoolset-8 gcc-c++ zlib-devel openmpi openmpi-devel
cd /mnt/nfs
wget -O - http://dl.openfoam.org/source/7 | tar xvz
wget -O - http://dl.openfoam.org/third-party/7 | tar xvz
mv OpenFOAM-7-version-7 OpenFOAM-7
mv ThirdParty-7-version-7 ThirdParty-7
export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/nfs/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
source ~/.bashrc
cd /mnt/nfs/OpenFOAM-7
./Allwmake -j
```

### ComputeNode
You just need mpi on the compute node. 


```
sudo yum -y install openmpi openmpi-devel
cd /mnt/nfs
export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/nfs/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
source ~/.bashrc
```

## Paraview

### GPU rendering
Select an installation directory. The Network File System is probably a good place to put it. If you are using GPUs along with x11vnc, Paraview runs on the GPU and the NVIDIA driver are being used. 

```
sudo yum install -y mesa-libGLU
cd /mnt/nfs/
curl -d submit="Download" -d version="v5.7" -d type="binary" -d os="Linux" -d downloadFile="ParaView-5.7.0-MPI-Linux-Python2.7-64bit.tar.gz" https://www.paraview.org/paraview-downloads/download.php > file.tar.gz
tar -xf file.tar.gz
```

To access paraview from a web browser, you can start a server on the GPU node: 

```
cd /mnt/nfs/ParaView-5.7.0-MPI-Linux-Python2.7-64bit
./bin/pvpython ./share/paraview-5.7/web/visualizer/server/pvw-visualizer.py  --content ./share/paraview-5.7/web/visualizer/www/ --data /mnt/nfs/ --port 8080
```

The TCP port that you choose need to be open in the firewall and in the security list. 

```
sudo firewall-offline-cmd --zone=public --add-port=8080/tcp
```

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

Select the VCN that you created. Select the Subnet in which the machine reside, probably your public subnet. Select the security list. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  

* CIDR : 0.0.0.0/0
* IP PROTOCOL: TCP
* Source Port Range: All
* Destination Port Range: 8080

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

### CPU rendering

Select an installation directory. The Network File System is probably a good place to put it. If you are using CPUs, we advise to use an older version of Paraview to avoid conflict with OpenGL. 

```
sudo yum install -y mesa-libGLU
cd /mnt/nfs/
curl -d submit="Download" -d version="v4.4" -d type="binary" -d os="Linux" -d downloadFile="ParaView-4.4.0-Qt4-Linux-64bit.tar.gz" https://www.paraview.org/paraview-downloads/download.php > file.tar.gz
tar -xf file.tar.gz
```

Start Paraview from a VNC session like this:
```
/mnt/nfs/ParaView-4.4.0-Qt4-Linux-64bit/bin/paraview
```
<!---


The architecture for this runbook is as follow, we have one small machine (bastion) that you will connect into. The compute nodes will be on a separate private network linked with RDMA RoCE v2 networking. The bastion will be accesible through SSH from anyone with the key (or VNC if you decide to enable it). Compute nodes will only be accessible through the bastion inside the network. This is made possible with 1 Virtual Cloud Network with 2 subnets, one public and one private.
 

## Architecture
In addition it authenticates all of the nodes on the cluster and creates a common share directory to be used for each of the nodes. A bastion host is created and a cluster of instances. A public IP is assigned to the network with port 22 open. The Jumpbox can be accessed with the following command:
```
   ssh {username}\@{bm-public-ip-address}
```
Four different types of file storage are created alongside the cluster. One NFS file share is created from the head node's OS disk and shared with all of the compute nodes, another share is created on the temp disk of the head node, /mnt/scratch. The temp disk is a physically attached disk and will typically provide faster performance on each of the nodes.
![](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/HPC_arch_draft.png "Architecture for running OpenFOAM in OCI")

## Licensing
Since OpenFOAM is open source there are no licensing considerations for this application.
## Running the Application
We will show an example on the OpenFOAM motorbike tutorial and how to tweak the default allrun file to match the architecture that we have built. 

First we will move the folder from the OpenFOAM installer folder. 

```
model_drive=/mnt/block #or /mnt/nvme or /mnt/fss
sudo mkdir $model_drive/work
sudo chmod 775 $model_drive/work
cp -r $FOAM_TUTORIALS/incompressible/simpleFoam/motorBike $model_drive/work
```

In this example, we are just running on 6 cores. Let's adapt this to the cluster we have built. Since creating and modifying cluster are so easy thanks to this guide, you can also make your cluster match the number of processes that you need. If you are just using the free trial, we can use 3 VM.Standard2.4 for a total of 12 cores. If your limits are higher, adapt this to however how many machines you want. 

Edit the file `system/decomposeParDict` and change this line `numberOfSubdomains 6;` to `numberOfSubdomains 12;` or how many processes you will need. 
Then in the hierarchicalCoeffs block, change the n from  `n   (3 2 1);` to `n   (4 3 1);` If you multiply those 3 values, you should get the `numberOfSubdomains`

Edit the Allrun file to look like this. 
```
#!/bin/sh
cd ${0%/*} || exit 1    # Run from this directory
NP=$1
install_drive=/mnt/block #or /mnt/nvme or /mnt/fss
# Source tutorial run functions
. $WM_PROJECT_DIR/bin/tools/RunFunctions

# Copy motorbike surface from resources directory
cp $FOAM_TUTORIALS/resources/geometry/motorBike.obj.gz constant/triSurface/
cp $install_drive/machinelist.txt hostfile

runApplication surfaceFeatures

runApplication blockMesh

runApplication decomposePar -copyZero
echo "Running snappyHexMesh"
mpirun -np $NP -machinefile hostfile snappyHexMesh -parallel -overwrite > log.snappyHexMesh
ls -d processor* | xargs -I {} rm -rf ./{}/0
ls -d processor* | xargs -I {} cp -r 0 ./{}/0
echo "Running patchsummary"
mpirun -np $NP -machinefile hostfile patchSummary -parallel > log.patchSummary
echo "Running potentialFoam"
mpirun -np $NP -machinefile hostfile potentialFoam -parallel > log.potentialFoam
echo "Running simpleFoam"
mpirun -np $NP -machinefile hostfile $(getApplication) -parallel > log.simpleFoam

runApplication reconstructParMesh -constant
runApplication reconstructPar -latestTime

foamToVTK
touch motorbike.foam
```

Now, we are ready to go. Before any run, it is always recommanded to clean the directory using the Allclean script. The argument to the Allrun script is the number of processes and should match `numberOfSubdomains` in the `system/decomposeParDict` file

```
./Allrun 12
```

Watch the magic happen !
## Post-processing

In terms of post-processing, ParaView is a really powerful opensource tool to visualize what is happening. 
Run the commands 
```
foamToVTK
touch motorbike.foam
```

Now open paraview, on GPU instances with a GPU post processing (as in x11vnc), we'll use the latest ParaView version. If you are just a regular VNC, take version 4.4 to avoid any problem with OpenGL libraries. 

Now run

```
ParaViewInstallPath/bin/paraview
```

You may have some error message popping up in the console but you can ignore those. Open the file motorbike.foam that we generated in the run folder and start playing with your model. 

--->
