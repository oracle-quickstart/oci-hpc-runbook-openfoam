# <img src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/openfoam.png" height="80"> Runbook

## Introduction
This runbook is designed to assist in the assessment of the OpenFOAM CFD Software in Oracle Cloud Infrastructure. It automatically downloads and configures OpenFOAM. 

OpenFOAM is the free, open source CFD software released and developed primarily by OpenCFD Ltd since 2004. It has a large user base across most areas of engineering and science, from both commercial and academic organisations. OpenFOAM has an extensive range of features to solve anything from complex fluid flows involving chemical reactions, turbulence and heat transfer, to acoustics, solid mechanics and electromagnetics.

<img align="middle" src="https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/images/sim.gif" height="180" >
 
# Architecture

2 slightly different architectures are possible to run OpenFOAM. 
* [Using regular VMs](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/free_trial.md) as you would for example using the [Free trial of Oracle Cloud](https://www.oracle.com/uk/cloud/free/)
* [Using HPC instances](https://github.com/oci-hpc/oci-hpc-runbook-openfoam/blob/master/RDMA.md) interconnected through RDMA 
