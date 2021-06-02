#!/bin/bash -v

# Stop the firewall to allow communication with the nodes
# TODO: find the exact ports to open
echo "gpu-start-app"
echo $*
sudo systemctl stop firewalld

# Add librairies
sudo yum install -y libSM libX11 libXext libXt openmpi openmpi-devel
echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
echo source /mnt/$2/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
source ~/.bashrc