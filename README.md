# <img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/openfoam.png" height="80"> Runbook

## Introduction
This runbook is designed to assist in the assessment of the OpenFOAM CFD Software in Oracle Cloud Infrastructure. It automatically downloads and configures OpenFOAM. 

OpenFOAM is the free, open source CFD software released and developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organisations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electromagnetics.

<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/sim.gif" height="180" >
 
# Architecture
<img align="middle" src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/HPC_arch_draft.png" height="500" >                             
## Phase 1. Run OpenFOAM

### Step 1. Navigate to Allrun
<pre>
cd /nfs/cluster/OpenFOAM/work
./Allrun
</pre>
                                                                                                                            
## Phase 2. Visualize the motorbike model on OCI

### Step 1. Connect to your remote host via VNC.

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

2. Establish a port mapping from port 5901 on your local machine to port 5901 on the remote host.
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

3. Execute the following command on your remote machine to launch a VNCServer instance on port 5901 on the remote host:
<p></p>
<pre>
vncserver
</pre>
<details>
	<summary>Port mapping from localhost to remote host. Note that the user in this example is using Mac OS as a local machine.</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/04-vnc-connection-port-mapping.png"/>
</div>
</details>

4. On your local machine, open VNC Viewer.

5. Enter <b>localhost:5901</b> into the search bar and press return.
<details>
	<summary>VNC Viewer</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/05-vnc-connection-vnc-viewer.png"/>
</div>
</details>

6. Enter the password <b>HPC_oci1</b> when prompted.

<details>
	<summary>Enter VNC password</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/06-vnc-connection-enter-password.png"/>
</div>
</details>

7. Click through the default options (<b>Next</b>, <b>Skip</b>) to get to the end with the VNC setup wizard:

<p></p>
<pre>
language options &gt keyboard layout options &gt location services options &gt connect online accounts options
</pre>
<details>
	<summary>GUI desktop options - choose language</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/07-vnc-connection-choose-language.png"/>
</div>
</details>

### Step 2.	Visualize the simulation using ParaView.

<!-- 2.1. Open Terminal from your VNC Viewer window:
<p></p>
<pre>
click <b>Applications</b> &gt hover over <b>System Utilities</b> &gt click <b>Terminal</b>
</pre>
<details>
	<summary>Navigate to Terminal on the remote host</summary>
<div style="text-align:center"><img src="https://github.com/oracle-quickstart/oci-hpc-runbook-openfoam/blob/main/images/08-vnc-connection-nav-to-terminal.png"/>
</div>
</details> -->

1. Open Files from your VNC Viewer window:
<p></p>
<pre>
click <b>Applications</b> &gt hover over <b>Accessories</b> &gt click <b>Files</b> &gt on the left side of the window, click <b>Home</b>
</pre>

<!-- 2.2. Open Paraview by executing the following command from the Terminal instance in your VNC Viewer window:
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
<!-- 2.3. In ParaView, open the motorbike.foam file:
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

                                                                                                                            
