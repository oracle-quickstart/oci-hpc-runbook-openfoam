#!/bin/bash -v
echo $*

NVIDIA_DRIVERS=`nvidia-smi 2>&1 | grep "command not found" | wc | awk '{ print $1}'`
echo NVIDIA_DRIVERS $NVIDIA_DRIVERS
VNC_VAR=$2
if [ $NVIDIA_DRIVERS -gt 0 ] && [ "$2" = "x11vnc" ]
then
    VNC_VAR=vnc
    echo "NVIDIA_Driver were not found"
fi

if [ $VNC_VAR = "vnc" ]
then
    sudo yum install -y mesa-libGLU
    cd /mnt/$1
    curl -d submit="Download" -d version="v4.4" -d type="binary" -d os="Linux" -d downloadFile="ParaView-4.4.0-Qt4-Linux-64bit.tar.gz" https://www.paraview.org/paraview-downloads/download.php > pv.tar.gz
    tar -xf pv.tar.gz
fi
if [ $VNC_VAR = "x11vnc" ]
then
    sudo yum install -y mesa-libGLU
    cd /mnt/$1
    curl -d submit="Download" -d version="v5.7" -d type="binary" -d os="Linux" -d downloadFile="ParaView-5.7.0-RC1-MPI-Linux-64bit.tar.gz" https://www.paraview.org/paraview-downloads/download.php > pv.tar.gz
    tar -xf pv.tar.gz
fi