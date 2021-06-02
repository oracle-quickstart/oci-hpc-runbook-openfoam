#!/bin/bash -v

echo "hn-start-app"
echo $*

# Stop the firewall to allow communication with the nodes
# TODO: find the exact ports to open
sudo systemctl stop firewalld

# Register the headnode as a compute node 
cpus=`lscpu | grep "CPU(s):" | grep -v NUMA | awk '{ print $2}'`
echo $1 cpu=$((cpus / 2 )) >> /mnt/$2/machinelist.txt


# Add librairies

if [ "$5" != "" ]
then
    echo Installing from source
    cd /mnt/$2
    sudo yum groupinstall -y 'Development Tools'
    sudo yum -y install devtoolset-8 gcc-c++ zlib-devel openmpi openmpi-devel
    wget -O - $5 | tar xvz
    wget -O - $6 | tar xvz
    mv OpenFOAM-7-version-7 OpenFOAM-7
    mv ThirdParty-7-version-7 ThirdParty-7
    export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
    echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
    echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
    echo source /mnt/$2/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
    sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
    source ~/.bashrc
    cd /mnt/$2/OpenFOAM-7
    ./Allwmake -j
else
    echo Using Compiled Binaries
    sudo yum -y install openmpi openmpi-devel
    cd /mnt/$2
    pwd
    echo $7 
    wget $7 -O - | tar x
    export PATH=/usr/lib64/openmpi/bin/:/usr/lib64/qt5/bin/:$PATH
    echo export PATH=/usr/lib64/openmpi/bin/:\$PATH | sudo tee -a ~/.bashrc
    echo export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib/:\$LD_LIBRARY_PATH | sudo tee -a ~/.bashrc
    echo source /mnt/$2/OpenFOAM-7/etc/bashrc | sudo tee -a ~/.bashrc
    sudo ln -s /usr/lib64/libboost_thread-mt.so /usr/lib64/libboost_thread.so
    source ~/.bashrc
fi

if [ "$4" != "" ]
then
    echo Downloading model
    mkdir /mnt/$2/work
    cd /mnt/$2/work
    wget -O - $4 | tar xvz
fi