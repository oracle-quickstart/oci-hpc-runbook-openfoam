# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook


# Deployment via web console

**Table of Contents**

- [<img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook](#img-src%22httpsgithubcomoci-hpcoci-hpc-runbook-openfoamblobmasterimagesopenfoampng%22-height%2280%22-runbook)
- [Deployment via web console](#deployment-via-web-console)
  - [Prerequisites](#prerequisites)
  - [Log In](#log-in)
  - [Virtual Cloud Network](#virtual-cloud-network)
    - [Subnets](#subnets)
    - [NAT Gateway](#nat-gateway)
    - [Security List](#security-list)
    - [Route Table](#route-table)
    - [Subnet](#subnet)
      - [Public](#public)
      - [Private](#private)
    - [Internet Gateway](#internet-gateway)
  - [Compute Instance](#compute-instance)
      - [Headnode](#headnode)
      - [Worker](#worker)
  - [NAT Gateway setup](#nat-gateway-setup)
    - [Worker nodes only](#worker-nodes-only)
  - [Mounting a drive](#mounting-a-drive)
  - [Creating a Network File System](#creating-a-network-file-system)
    - [Headnode](#headnode-1)
    - [Worker Nodes](#worker-nodes)
- [Installation](#installation)
  - [Connecting all worker nodes](#connecting-all-worker-nodes)
  - [Create a machinelist](#create-a-machinelist)
  - [OpenFOAM](#openfoam)
    - [Headnode](#headnode-2)
    - [Workernode](#workernode)
  - [Paraview](#paraview)
    - [GPU rendering](#gpu-rendering)
    - [CPU rendering](#cpu-rendering)
  - [Setting up VNC](#setting-up-vnc)
  - [Accessing a VNC](#accessing-a-vnc)
  - [Running the application](#running-the-application)

## Prerequisites

This hands on lab will assume that you have successfully completed the OCI Cloud Architect Associate exam and are already familiar with the OCI console, Virtual Cloud Network, Compute, and Storage services. If you haven't compeleted the Associate level exam, please [follow this link to get started.](https://www.oracle.com/cloud/iaas/training/)

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Virtual Cloud Network
Before creating an instance, we need to configure a Virtual Cloud Network. Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Networking and Virtual Cloud Networks. <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_vcn.png" height="20">

On the next page, select the following for your VCN: 
* Name
* Compartment
* CIDR Block (example: 10.0.0.0/16)

Scroll to the bottom and click Create VCN

### Subnets
Based on our cluster architecture, we will need to create a private subnet for compute nodes that is protected from the public internet that is accessible only from the headnode, known as the bastion host.

We have two requirements for the private subnet: 
1. Only the bastion host can access nodes in the subnet
2. The nodes in the subnet should be able download packages from the public internet

To accomplish both of those things we will create a security rule allowing ingress only from the public subnet and a NAT gateway to access the repositories from the public internet

### NAT Gateway

In the ressource menu on the left side of the page, select NAT Gateways.

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/resources_menu.png" height="200">

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">

Enter a name (example: openfoam_nat) and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/NAT.png" height="20">


### Security List
In the resource menu on the left side of the page, select Security Lists.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

Enter a name (example: openfoam_private_sec_list)

Add an Ingress Rule with the following settings:
* Stateless: unchecked
* Source Type: CIDR 
* Source CIDR: CIDR from the initial VCN creation step
* IP Protocol: All Protocols

Add an Egress Rule with the following settings:
* Stateless: unchecked
* Destination Type: CIDR 
* Destination CIDR: 0.0.0.0/0
* IP Protocol: All Protocols

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_sl.png" height="20">

To allow the creation of a Network File System (NFS) as defined in the architecture, we need to add a couple of ingress rules to the Default Security List. Click on the Security List that begins with "Default Security List for...". 

Add an ingress rule for TCP on all ports for NFS. 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  
* Stateless: unchecked
* Source Type: CIDR
* Source CIDR : 10.0.0.0/16
* IP Protocol: TCP
* Source Port Range: All
* Destination Port Range: All

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 

Add another ingress rule for UDP on specific ports for NFS:

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20">  
* Stateless: unchecked
* Source Type: CIDR
* Source CIDR : 10.0.0.0/16
* IP Protocol: UDP
* Source Port Range: All
* Destination Port Range: 111,2049

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/addIngress.png" height="20"> 


### Route Table
Return to the page for your deployment's VCN. In the resource menu on the left side of the page, click on Route Tables.

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

Enter a name for your Route Table (example: openfoam_private_RT)

Add an additional route rule with these settings:

* Target Type : NAT Gateway
* Destination CIDR Block : 0.0.0.0/0
* Target NAT Gateway: Select the previously created NAT gateway from above (example: openfoam_nat)

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_rt.png" height="20">

### Subnet
The VCN will need two subnets, one for the head node, which will have public internet access, and one for the worker nodes, which will be private.

In the resource menu on the left side of the page, select Subnets.
Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

Choose the following settings:

#### Public
* Name : (example: openfoam_public_subnet)
* Subnet Type: Regional
* CIDR Block: 10.0.0.0/24
* Route Table: Select "Default Route Table..."
* Subnet Access: Public Subnet
* Security List: Select "Default Security List..."

#### Private
* Name : (example: openfoam_private_subnet)
* Subnet Type: Regional
* CIDR Block: 10.0.3.0/24
* Route Table: Select Route Table from previous step (example: openfoam_private_RT)
* Subnet Access: Private Subnet
* Security List: Select private Security List from previous step (example: openfoam_private_sec_list)

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/raw/master/images/create_subnet.png" height="20">

### Internet Gateway

From the Virtual Cloud Networks list page, click on the name of the VCN that was created in the previous step. 

In the ressource menu on the left side of the page, select Internet Gateways and Create Internet Gateway.

Enter a name (example: openfoam_internet_gateway)

Click create

That will create the internet gateway, and it will need to be associated with a route table. In this case, since the Default Route Table will be used for the public subnet, the internet gateway should be associated with that route table.

On the left select Route Tables, and lcick on "Default Route Table for..."

Click Add Route Rules and fill out the form with these settings:

* Target Type: Internet Gateway
* Destination CIDR Block: 0.0.0.0/0
* Target Internet Gateway in...: Select the internet gateway created (example: openfoam_internet_gateway)

Click Add Route Rule

## Compute Instance
With the VCN setup we can move on to creating the actual compute nodes. For this lab we will be utilizing only the basic VM.Standard2.1 shape, but for an actual deployment a larger shape like BM.HPC2.36 would be appropriate. Some high performance shapes are only available in specific Regions and Availability Domains.

We will create two nodes for this lab, the headnode for the cluster on the public subnet, and a worker compute node in the private subnet. In order to access the worker nodes, we will first create the headnode, then generate a ssh key on the headnode, and use that public key when creating the worker node.

Create a new instance by selecting the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Compute and Instances. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Instances.png" height="300">

On the next page, click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="25">

On the creation page, select the following:

#### Headnode
* Name of your instance (example: openfoam_head)
* Image or operating system: latest version Oracle Linux (default).
* Availibility Domain: Any domain will suffice for VM.Standard2.1 shapes
* Instance Shape: 
  * VM.Standard2.1  (default)
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* Virtual Cloud Network: Select the VCN created previously
* Subnet: Select the public subnet created previously
* SSH key: Attach your public key file. [For more information](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/creatingkeys.htm).

After a few minutes, the instance will turn green meaning it is up and running. 

You can now use SSH log in to the headnode. Click on the name of the instance in the instance list and retrieve the public IP address under Instance Access on the Instance Information tab. In a terminal application, execute `ssh opc@xx.xx.xx.xx` to log in. 

On the headnode we will create a ssh key specific for the cluster to allow all machines to talk to each other using ssh. Log on to the headnode you created and run the command `ssh-keygen`. Do not change the file location (/home/opc/.ssh/id_rsa) and hit enter when asked about a passphrase (twice).

With that file created, run `cat ~/.ssh/id_rsa.pub`, which will output the contents of the public key to the console. The string will start with "ssh-rsa" and end with the name of the instance. Copy the whole string, which will be used in creating the worker node.

Since the worker nodes are in a private subnet we will not be able to communicate with them directly through the public internet. 

#### Worker
* Name of your instance (example: openfoam_worker_0)
* Image or operating system: latest version Oracle Linux (default).
* Availibility Domain: Any domain will suffice for VM.Standard2.1 shapes
* Instance Shape: 
  * VM.Standard2.1  (default)
  * Other shapes are available as well, [click for more information](https://cloud.oracle.com/compute/bare-metal/features).
* Virtual Cloud Network: Select the VCN created previously
* Subnet: Select the private subnet
* Paste SSH key: public key string copied from step above 

Click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_instance.png" height="20">

Return to the console logged in to the head node, and when the instance turns green, take the private IP address and try to use ssh to log in to the instance from the head node `ssh opc@10.x.x.x`

## NAT Gateway setup
### Worker nodes only

For a worker node to be able to access the NAT Gateway, select the worker node and in the Resources menu on the left, click on Attached VNICs. 

There will already be a Primary VNIC, click on the three dots at the end of the line and select "Edit VNIC"

Uncheck "Skip Source/Destination Check" if it is checked and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/updateVNIC.png" height="20">

## Mounting a drive
 ** Only if the node shape has a NVMe attached (BM.HPC2.36 has one, not VM.Standard2.1) **

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
sudo mkdir /mnt/local
sudo mount /dev/nvme0n1p1 /mnt/share
sudo chmod 777 /mnt/share
sudo mount /dev/nvme0n1p2 /mnt/local
sudo chmod 777 /mnt/local
```

Head Node (share):
```
sudo mkdir /mnt/share
sudo mount /dev/nvme0n1 /mnt/share
sudo chmod 777 /mnt/share
```

## Creating a Network File System

In the OCI console, click on the Menu button and hover over File Storage and click Mount Targets.

Click Create Mount Target with the following settings:

* New Mount Target Name: Enter a name (example: openfoam_fs)
* Virtual Cloud Network: Select the VCN created above
* Subnet: Select the public VCN

Click Create File System

Check that the Mount Target Name is the Mount Target created in the previous step

### Headnode

Since the headnode is in a public subnet, we will keep the firewall up and add an exception through. 
```
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --reload
```
We will also activate the nfs-server and make the directory:

```
sudo yum -y install nfs-utils
sudo systemctl enable nfs-server.service
sudo systemctl start nfs-server.service
sudo mkdir /mnt/share
sudo chmod 777 /mnt/share
```

Edit the file /etc/exports with vim or your favorite text editor. `sudo vi /etc/exports` and add the line `/mnt/share   10.0.0.0/16(rw)`

To activate those changes:

```
sudo exportfs -a
```

### Worker Nodes

On the worker nodes, since they are in a private subnet with security list restricting access, we can disable the firewall altogether. Then, we can install nfs-utils tools and mount the drive. 

To mount the drive, the private IP of the headnode will be required.  You can find it in the instance details in the OCI console under instance details where the public IP is presented, or find it by running the command `ifconfig` on the headnode. It will probably be something like 10.0.0.2, 10.0.1.2 or 10.0.2.2 depending on the CIDR block of the public subnet. 

```
sudo systemctl stop firewalld
sudo yum -y install nfs-utils
sudo mkdir /mnt/share
sudo mount <headnode-private-ip-address>:/mnt/share /mnt/share
```

# Installation
This section will show the different steps for the latest Oracle Linux image available on Oracle Cloud Infrastructure.  

## Connecting all worker nodes

Each worker node needs to be able to talk to all the worker nodes. SSH communication works but most applications have issues if all the hosts are not in the known host file. To disable the known host check for nodes with address in the VCN, you can deactivate with the following commands. You may need to modify it slightly if your have different addresses in your subnets. 

```
for i in 0 1 2 3
do
    echo Host 10.0.$i.* | sudo tee -a ~/.ssh/config
    echo "    StrictHostKeyChecking no" | sudo tee -a ~/.ssh/config
done
```

## Create a machinelist
 
OpenFOAM on the headnode does not automatically know which compute nodes are available. You can create a machinefile at `/mnt/share/machinelist.txt` with the private IP address of all the nodes along with the number of CPUs available. The headnode should also be included. The format for the entries is `<private-ip-address> cpu=<number-of-cores>`

Example:
```
10.0.0.2 cpu=1
10.0.3.2 cpu=1
```

## OpenFOAM

### Headnode
If you have the correct binaries of your OpenFOAM version. Just untar it and you are ready to go. 

If you want to install from sources, modify the path to the tarballs in the next commands. This example has the foundation OpenFOAM sources. OpenFOAM from ESI has also been tested. To share the installation between the different compute nodes, install on the network file system.   

```
sudo yum groupinstall -y 'Development Tools'
sudo yum -y install devtoolset-8 gcc-c++ zlib-devel openmpi openmpi-devel
cd /mnt/share
wget -O - http://dl.openfoam.org/source/7 | tar xvz
wget -O - http://dl.openfoam.org/third-party/7 | tar xvz
mv OpenFOAM-7-version-7 OpenFOAM-7
mv ThirdParty-7-version-7 ThirdParty-7
export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/share/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
source ~/.bashrc
cd /mnt/share/OpenFOAM-7
./Allwmake -j
```

### Workernode
You just need mpi on the compute node. 


```
sudo yum -y install openmpi openmpi-devel
cd /mnt/share
export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/share/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
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
cd /mnt/share/
curl -d submit="Download" -d version="v4.4" -d type="binary" -d os="Linux" -d downloadFile="ParaView-4.4.0-Qt4-Linux-64bit.tar.gz" https://www.paraview.org/paraview-downloads/download.php > file.tar.gz
tar -xf file.tar.gz
```

## Setting up VNC

By default, the only access to the Oracle Linux machine is through SSH in a console mode. If you want to see the graphical interface, you will need to set up a VNC connection. The following script will work for the default user opc. The password for the vnc session is set as "HPC_oci1" but it can be edited in the next set of commands.

If you are not currently connected to the headnode via SSH, please do so as these commands need to be run on the headnode.

```
sudo yum -y groupinstall 'Server with GUI'
sudo yum -y install tigervnc-server mesa-libGL
sudo mkdir /home/opc/.vnc/
sudo chown opc:opc /home/opc/.vnc
echo "HPC_oci1" | vncpasswd -f > /home/opc/.vnc/passwd
chown opc:opc /home/opc/.vnc/passwd
chmod 600 /home/opc/.vnc/passwd
/usr/bin/vncserver
```

The last command will output text like this:

```
New 'openfoam-head:N (opc)' desktop is openfoam-head:N

Starting applications specified in /home/opc/.vnc/xstartup
Log file is /home/opc/.vnc/openfoam-head:N.log
```

Note the number in place of 'N' above as we will use it when creating an SSH tunnel to connect to the instance.

## Accessing a VNC
We will connect through an SSH tunnel to the instance. On your machine, connect using ssh 

`PORT` below will be the number that results from 5900 + N above. If the output for N was 1, `PORT` is 5901, if the output was 34, `PORT` is 5934

public_ip is the public IP address of the headnode, which is running the VNC server.

```
ssh -L `PORT`:127.0.0.1:`PORT` opc@public_ip
```

You can now connect using any VNC viewer using localhost:N as VNC server and the password you set during the vnc installation. 

You can chose a VNC client that you prefer or use this guide to install on your local machine: 
[Windows - TigerVNC](https://github.com/TigerVNC/tigervnc/wiki/Setup-TigerVNC-server-%28Windows%29)
[MacOS/Windows - RealVNC](https://www.realvnc.com/en/connect/download/)

## Running the application

Once you are logged in through VNC, start a terminal window and run paraview:

Start Paraview from a VNC session like this:
```
/mnt/share/ParaView-4.4.0-Qt4-Linux-64bit/bin/paraview
```

We will show an example on the OpenFOAM motorbike tutorial and how to tweak the default allrun file to match the architecture that we have built.

First we will move the folder from the OpenFOAM installer folder.

```
model_drive=/mnt/share
sudo mkdir $model_drive/work
sudo chmod 777 $model_drive/work
cp -r $FOAM_TUTORIALS/incompressible/simpleFoam/motorBike $model_drive/work
cd /mnt/share/work/motorBike/system
```

Edit the file system/decomposeParDict and change this line numberOfSubdomains 6; to numberOfSubdomains 12; or how many processes you will need. Then in the hierarchicalCoeffs block, change the n from n (3 2 1); to n (4 3 1); If you multiply those 3 values, you should get the numberOfSubdomains

For running with a configuration of 1 VM.Standard2.1 worker node:

```/*--------------------------------*- C++ -*----------------------------------*\
  =========                 |
  \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox
   \\    /   O peration     | Website:  https://openfoam.org
    \\  /    A nd           | Version:  7
     \\/     M anipulation  |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      decomposeParDict;
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

numberOfSubdomains 2;

method          hierarchical;
// method          ptscotch;

simpleCoeffs
{
    n               (4 1 1);
    delta           0.001;
}

hierarchicalCoeffs
{
    n               (2 1 1);
    delta           0.001;
    order           xyz;
}

manualCoeffs
{
    dataFile        "cellDecomposition";
}


// ************************************************************************* //
```


Next edit the Allrun file in /mnt/share/work/motorBike to look like this:

```
#!/bin/sh
cd ${0%/*} || exit 1    # Run from this directory
NP=$1
install_drive=/mnt/share
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

Execute the run by running `Allrun 2` in the motorBike directory
If during the run there are errors, check back that your instructions and configuration are correct. When executing the next run, run `Allclean` first.

Once that has completed, return to Paraview and open the motorbike.foam file using File > open and navigating to the motorBike folder.
You can load the model and take a look at the results from the simulation in 3D space.
