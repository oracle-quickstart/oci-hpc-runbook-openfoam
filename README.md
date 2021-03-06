# <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/openfoam.png" height="80"> Runbook

## Introduction
This runbook is designed to assist in the assessment of the OpenFOAM CFD Software in Oracle Cloud Infrastructure. It automatically downloads and configures OpenFOAM. 

OpenFOAM is the free, open source CFD software released and developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organisations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electromagnetics.

For details of the architecture, see [_High Performance Computing: OpenFOAM on Oracle Cloud Infrastructure_](https://docs.oracle.com/en/solutions/hpc-openfoam/index.html)

<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/sim.gif" height="180" >
 
## Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `network-security-groups`, `subnets`, and `instances`.

- Quota to create the following resources: 1 VCN, 2 subnets, 1 Internet Gateway, 1 NAT Gateway, 1 Service Gateway, 3 route rules, and minimum 2 compute instances in instance pool or cluster network (plus bastion host).

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/releases/latest/download/oci-hpc-runbook-openfoam-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI

### Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam.git
    cd oci-hpc-runbook-openfoam
    ls

### Set Up and Configure Terraform

1. Complete the prerequisites described [here](https://github.com/cloud-partners/oci-prerequisites).

2. Create a `terraform.tfvars` file, and specify the following variables:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Availablity Domain 
ad = "<availablity doman>" # for example "GrCH:US-ASHBURN-AD-1"

# Bastion 
bastion_ad               = "<availablity doman>" # for example "GrCH:US-ASHBURN-AD-1"
bastion_boot_volume_size = "<bastion_boot_volume_size>" # for example 50
bastion_shape            = "<bastion_shape>" # for example "VM.Standard.E3.Flex"
boot_volume_size         = "<boot_volume_size>" # for example 100
node_count               = "<node_count>" # for example 2
ssh_key                  = "<ssh_key>"
targetCompartment        = "<targetCompartment>" 
use_custom_name          = false
use_existing_vcn         = false
use_marketplace_image    = true
use_standard_image       = true
cluster_network          = false
instance_pool_shape      = "<instance_pool_shape>" # for example VM.Standard.E3.Flex

````

### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

# Architecture

<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/architecture-hpc.png" height="500"> 

The above baseline infrastructure provides the following specifications:
-	Networking
    -	1 x 100 Gbps RDMA over converged ethernet (ROCE) v2
    -	Latency as low as 1.5 ??s
-	HPC Compute Nodes (BM.HPC2.36)
    -	6.4 TB Local NVME SSD storage per node
    -	36 cores per node
    -	384 GB memory per node
                           
## Phase 1. Run OpenFOAM

### Step 1. Navigate to your bastion

1. Find the public IP address of your remote host after the deployment job has finished:
<details>
	<summary>Resource Manager</summary>
	<p></p>
	If you deployed your stack via Resource Manager, find the public IP address of the compute node at the bottom of the CLI console logs.
	<p></p>
</details>
<details>
	<summary>Command Line</summary>
	<p></p>
	If you deployed your stack via Command Line, find the public IP address of the compute node at the bottom of the console logs on the <b>Logs</b> page, or on the <b>Outputs</b> page.
	<p></p>
</details>

> ssh -i **PRIVATE KEY PATH** opc@**IP_ADDRESS**

### Step 2. ssh into cluster

> ssh hpc-node-1


### Step 3. Make sure your bashrc is correct - it should look like the one below

> vi ~/.bashrc

```
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias status='tail /home/opc/autoscaling/logs/crontab_slurm.log | grep -A50 -m1 -e `date +"%Y-%m-%d"`'
export PATH=/usr/mpi/gcc/openmpi-4.1.0rc5/bin/:$PATH
export LD_LIBRARY_PATH=/usr/mpi/gcc/openmpi-4.1.0rc5/lib64/:$LD_LIBRARY_PATH
source /nfs/cluster/OpenFOAM/install/OpenFOAM/OpenFOAM-7/etc/bashrc
```
> source ~/.bashrc

### Step 4. Navigate to OpenFOAM directory 

> cd /nfs/cluster/OpenFOAM/work

### Step 5. Run OpenFOAM 

> ./Allrun **NUM OF CORES**

                                                                                                                            
## Phase 2. Visualize the motorbike model on OCI

### Step 1.     Set up VNC Viewer
 1. Run the following commands in your bastion: 
```
sudo yum -y groupinstall  "Server with GUI"
sudo yum -y install tigervnc-server
vncpasswd
vncserver
```
Give a password when prompted after running `vncpasswd`

`exit` from your bastion 
	
### Step 3. Connect to your remote host via VNC.

1. Establish a port mapping from port 5901 on your local machine to port 5901 on the remote host.
<details>
	<summary>Unix-based OS</summary>
	<p></p>
	Establish the port mapping using the following command:
	<p></p>
	<pre>
	ssh -i <b>SSH_PRIVATE_KEY_PATH</b> -L 5901:localhost:5901 opc@<b>REMOTE_HOST_IP_ADDRESS</b>
	</pre>
</details>
<details>
	<summary>Windows</summary>
	<p></p>
	<details>
		<summary>a. Establish the port mapping</summary>
		<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/01-putty-ssh-port-mappings-for-vnc"/>
		</div>
	</details>
	<p></p>
	<details>
		<summary>b. Encrypt the SSH tunnel</summary>
		<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/02-putty-encrypted-ssh-tunnel"/>
		</div>
	</details>
</details>
<p></p>

2. Execute the following command on your remote machine to launch a VNCServer instance on port 5901 on the remote host:
<p></p>
<pre>
vncserver
</pre>
<details>
	<summary>Port mapping from localhost to remote host. Note that the user in this example is using Mac OS as a local machine.</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/04-vnc-connection-port-mapping.png"/>
</div>
</details>

3. On your local machine, open VNC Viewer.

4. Enter <b>localhost:5901</b> into the search bar and press return.
<details>
	<summary>VNC Viewer</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/05-vnc-connection-vnc-viewer.png"/>
</div>
</details>

5. Enter the password <b>HPC_oci1</b> when prompted.

<details>
	<summary>Enter VNC password</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/06-vnc-connection-enter-password.png"/>
</div>
</details>

6. Click through the default options (<b>Next</b>, <b>Skip</b>) to get to the end with the VNC setup wizard:

<p></p>
<pre>
language options &gt keyboard layout options &gt location services options &gt connect online accounts options
</pre>
<details>
	<summary>GUI desktop options - choose language</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/07-vnc-connection-choose-language.png"/>
</div>
</details>

### Step 3.	Visualize the simulation using ParaView.

<!-- 3.1. Open Terminal from your VNC Viewer window:
<p></p>
<pre>
click <b>Applications</b> &gt hover over <b>System Utilities</b> &gt click <b>Terminal</b>
</pre>
<details>
	<summary>Navigate to Terminal on the remote host</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/08-vnc-connection-nav-to-terminal.png"/>
</div>
</details> -->

1. Open up terminal
<p></p>
<pre>
click <b>Applications</b> &gt hover over <b>System Tools</b> &gt click <b>Terminal</b> 
</pre>

<!-- 3.2. Open Paraview by executing the following command from the Terminal instance in your VNC Viewer window:
<p></p>
<pre>
cd /nfs/cluster/paraview/ParaView-4.4.0-Qt4-Linux-64bit/bin
</pre>
<details>
	<summary>Run ParaView on the remote host</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/09-vnc-connection-run-paraview.png"/>
</div>
</details> -->
	
2. Open ParaView via Terminal:
<p></p>
<pre>
cd /nfs/cluster/paraview/ParaView-4.4.0-Qt4-Linux-64bit/bin
./paraview
</pre>
<!-- 3.3. In ParaView, open the motorbike.foam file:
<p></p>
<pre>
File > Open > choose <b>/nfs/cluster/OpenFOAM/work/motorbike.foam</b>
</pre>
<details>
	<summary>Open motorbike.foam in ParaView</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/10-paraview-open-motorbike-file.png"/>
</div>
</details> -->
3. In ParaView, open the motorbike.foam file:
<p></p>
<pre>
File > Open > choose <b>/home/opc/work/motorbike.foam</b>
</pre>
<details>
	<summary>Open motorbike.foam in ParaView</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/10-paraview-open-motorbike-file.png"/>
</div>
</details>

4. Under the <b>Properties</b> pane on the left side of Paraview, select <b>Mesh Regions</b> to select everything, and then deselect the options that do not start with the string <b>motorBike_</b>. You can adjust the windows to make this section of the GUI easier to access e.g. by closing <b>PipeLine Browser</b> section by clicking <b>X</b>.

<details>
	<summary>Before selection of <b>motorBike_</b> options</summary>
	<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/11-paraview-before-select.png"/>
	</div>
</details>
<details>
	<summary>After selection of <b>motorBike_</b> options</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/12-paraview-after-select.png"/>
</div>
</details>

5. Click the green <b>Apply</b> button to render the motorbike image. If a window with a list of errors appears, titled <b>Output Messages</b>, you may close it.
<p></p>

6. The motorbike model should appear in the large window titled <b>RenderView1</b>. Use your mouse and its left-click button to manipulate it in virtual 3D space!
<details>
	<summary>Motorbike model</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/13-paraview-motorbike.png"/>
</div>
</details>

                                                                                                                            
