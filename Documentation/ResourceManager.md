# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook



# Deployment through Resource Manager

**Table of Contents**
- [Deployment through Resource Manager](#deployment-through-resource-manager)
  - [Log In](#log-in)
  - [Resource Manager](#resource-manager)
  - [Add OpenFOAM binaries to Object Storage](#add-openfoam-binaries-to-object-storage)
  - [Select variables](#select-variables)
  - [Run the stack](#run-the-stack)
  - [Access your cluster](#access-your-cluster)
  

## Log In
You can start by logging in the Oracle Cloud console. If this is the first time, instructions to do so are available [here](https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/signingin.htm).
Select the region in which you wish to create your instance. Click on the current region in the top right dropdown list to select another one. 

<img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/Region.png" height="50">

## Resource Manager
In the OCI console, there is a Resource Manager available that will create all the resources needed. 

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Resource Manager and Stacks. 

Create a new stack: <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/stack.png" height="20">

Download the [ZIP file](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/raw/master/Resources/openfoam.zip) for OpenFOAM

Download this [ZIP file](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/raw/master/Resources/openfoam_demo.zip) if you are following the Webinar and testing with a trial account.

Upload the ZIP file

Choose the Name and Compartment

## Add OpenFOAM binaries to Object Storage

There is a couple ways to install OpenFOAM, provide the compiled binaries or to build the sources. Building from sources is taking longer but the binaries need to be rebuilt for different platforms.

Select the menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/menu.png" height="20"> on the top left, then select Object Storage and Object Storage.

Create a new bucket or select an existing one. To create one, click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">

Leave the default options: Standard as Storage tiers and Oracle-Managed keys. Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create_bucket.png" height="20">

Click on the newly created bucket name and then select <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">

Select your file and click <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/upload_object.png" height="20">

Click on the 3 dots to the right side of the object you just uploaded <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/3dots.png" height="20"> and select "Create Pre-Authenticated Request". 

In the following menu, leave the default options and select an expiration date for the URL of your installer. Click on  <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/pre_auth.png" height="25">

In the next window, copy the "PRE-AUTHENTICATED REQUEST URL" and keep it. You will not be able to retrieve it after you close this window. If you loose it or it expires, it is always possible to recreate another Pre-Authenticated Request that will generate a different URL. 


## Select variables

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20"> and fill in the variables. 

* AD: Availability Domain of the cluster (1,2 or 3)
* COMPUTENODE_COUNT: Number of compute machines (Integer)
* COMPUTE_SHAPE: Shape of the Compute Node (BM.HPC2.36)
* HEADNODE_SHAPE: Shape of the Head Node which is also a Compute Node in our architecture (BM.HPC2.36)
* GPUNODE_COUNT: Number of GPU machines for Pre/Post
* GPUPASSWORD: password to use the VNC session on the Pre/Post Node
* GPU_AD: Availability Domain of the GPU Machine (1, 2 or 3)
* GPU_SHAPE: Shape of the Compute Node (VM.GPU2.1, BM.GPU2.2,...)
* OPENFOAM_BINARIES: URL of the OpenFOAM binaries
* OPENFOAM_SOURCES: URL of the OpenFOAM sources. Both ESI and foundation have been tested

Click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/next.png" height="20">

Review the informations and click on <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/create.png" height="20">

## Run the stack

Now that your stack is created, you can run jobs. 

Select the stack that you created.
In the "Terraform Actions" dropdown menu <img src="https://github.com/oci-hpc/oci-hpc-runbook-shared/blob/master/images/tf_actions.png" height="20">, run terraform apply to launch the cluster and terraform destroy to delete it. 

## Access your cluster

Once you have created your cluster, if you gave a valid URL for the OpenFOAM sources or binaries, no other action will be needed except [running your jobs](https://github.com/oci-hpc/oci-hpc-runbook-openfoam#running-the-application).

Public IP addresses of the created machines can be found on the lower left menu under Outputs. 

The Private Key to access the machines can also be found there. Copy the text in a file on your machine, let's say /home/user/key. 

```
chmod 600 /home/user/key
ssh -i /home/user/key opc@ipaddress
```

Access to the GPU instances, or to the headnode can be done through a SSH tunnel:

```
ssh -i /home/user/key -L 5902:127.0.0.1:5900 opc@ipaddress
```

And then connect to a VNC viewer with localhost:2.

The default opc password has been set to `HPC_oci1`

[More information](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/Documentation/ManualDeployment.md#accessing-a-vnc) about using a VNC session. 


