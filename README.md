# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook

## Introduction
This runbook is designed to assist in the assessment of the OpenFOAM CFD Software in Oracle Cloud Infrastructure. It automatically downloads and configures OpenFOAM. 

OpenFOAM is the free, open source CFD software released and developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organisations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electromagnetics.

<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/sim.gif" height="180" >
 
# Architecture Diagram 

<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/arch.png" height="500" >

# Login
Login to the using opc as a username:
```
   ssh {username}\@{bm-public-ip-address} -i id_rsa
```
Note that if you are using resource manager, obtain the private key from the output and save on your local machine. 

# Prerequisites

- Permission to `manage` the following types of resources in your Oracle Cloud Infrastructure tenancy: `vcns`, `internet-gateways`, `route-tables`, `security-lists`, `subnets`, and `instances`.

- Quota to create the following resources: 1 VCN, 1 subnet, 1 Internet Gateway, 1 route rules, and 1 GPU (VM/BM) compute instance.

If you don't have the required permissions and quota, contact your tenancy administrator. See [Policy Reference](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/policyreference.htm), [Service Limits](https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/servicelimits.htm), [Compartment Quotas](https://docs.cloud.oracle.com/iaas/Content/General/Concepts/resourcequotas.htm).

# Deployment
Deploying this architecture on OCI can be done in different ways:

## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-quickstart/oci-hpc-runbook-gromacs/releases/latest/download/oci-hpc-runbook-gromacs-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 
8. ## Deploy Using the Terraform CLI

### Clone the Module
Now, you'll want a local copy of this repo. You can make that with the commands:

    git clone https://github.com/oracle-quickstart/oci-hpc-runbook-gromacs.git
    cd oci-hpc-runbook-gromacs
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

# Compartment
compartment_ocid = "<compartment_ocid>"

# Availability Domain
availablity_domain_name = "<availablity_domain_name>" # for example GrCH:US-ASHBURN-AD-1

````
### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

## Deploy Using OCI Console

* The [web console](https://github.com/oracle-quickstart/oci-hpc-runbook-gromacs/blob/master/Documentation/ManualDeployment.md#deployment-via-web-console) let you create each piece of the architecture one by one from a webbrowser. This can be used to avoid any terraform scripting or using existing templates. 

## Licensing
See [Third Party Licenses](https://github.com/oracle-quickstart/oci-hpc-runbook-gromacs/blob/master/Third_Party_Licenses) for Gromacs and terraform licensing, including dependencies used in this tutorial.

## Running the Application
If the provided terraform scripts are used to launch the application, Gromacs is installed in the /mnt/block/gromacs folder and the example benchmarking model is available in /mnt/block/work folder. Run Gromacs via the following commands:

1. Run Gromacs on OCI GPU shapes via the following command:
   ```
    gmx mdrun -s <file path> -ntmpi <# of cores> -gpu_id <GPU devices to use>
   ```
   where:
     * mdrun = program that reads the input file and execues the computational chemistry analysis
     * -s = the input file
     * -ntmpi = the number of thread-MPI threads to start 
     * -gpu_id = the string of digits (without delimiter) representing device id-s of the GPUs to be used

   Example for VM.GPU2.1:
   ```
   gmx mdrun -s gromacs_benchMEM.tpr
   ```

   Example for BM.GPU2.2:
   ```
   gmx mdrun -s gromacs_benchMEM.tpr -ntmpi 24 -gpu_id 01
   ```

   Example for BM.GPU3.8:
   ```
   gmx mdrun -s gromacs_benchMEM.tpr -ntmpi 48 -gpu_id 01234567
   ```

2. Once the run is complete, refer to the bottom of the terminal for performance numbers. The run will show the ns/day for the number of cores that were run.


## Post-processing

For post-processing, you can use ParaView to visualize model. 

If you are using vnc, launch vncserver and create a vnc password as follows:
```
sudo systemctl start vncserver@:1.service
sudo systemctl enable vncserver@:1.service
vncserver
vncpasswd
```

Start up a vnc connection using localhost:5901 (ensure tunneling is configured), and run the following commands to start up ParaView:
```
cd /nfs/cluster
./paraview
```
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

