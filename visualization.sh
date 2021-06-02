#!/bin/bash -v
echo $*

NVIDIA_DRIVERS=`nvidia-smi 2>&1 | grep "command not found" | wc | awk '{ print $1}'`
echo NVIDIA_DRIVERS $NVIDIA_DRIVERS
VNC_VAR=$1
if [ $NVIDIA_DRIVERS -gt 0 ] && [ $1 = "x11vnc" ]
then
    VNC_VAR=vnc
    echo "NVIDIA_Driver were not found, installing tigervnc"
fi

if [ $VNC_VAR = "vnc" ]
then
    #Set up a VNC session
    sudo yum -y groupinstall 'Server with GUI'
    sudo yum -y install tigervnc-server mesa-libGL
    sudo systemctl set-default graphical.target
    sudo cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:0.service
    sudo sed -i 's/<USER>/opc/g' /etc/systemd/system/vncserver@:0.service
    sudo mkdir /home/opc/.vnc/
    sudo chown opc:opc /home/opc/.vnc
    echo $2 | vncpasswd -f > /home/opc/.vnc/passwd
    chown opc:opc /home/opc/.vnc/passwd
    chmod 600 /home/opc/.vnc/passwd
    sudo systemctl start vncserver@:0.service
    sudo systemctl enable vncserver@:0.service
fi
if [ $VNC_VAR = "x11vnc" ]
then
    #Set up a x11vnc session
    sudo yum -y groupinstall 'Server with GUI'
    sudo yum -y install x11vnc mesa-libGL
    sudo nvidia-xconfig -a --busid PCI:0:4:0 --no-connected-monitor
    sudo systemctl isolate multi-user.target
    sudo systemctl isolate graphical.target
    sudo mkdir /home/opc/.vnc/
    sudo chown opc:opc /home/opc/.vnc
    echo $2 | vncpasswd -f > /home/opc/.vnc/passwd
    chown opc:opc /home/opc/.vnc/passwd
    chmod 600 /home/opc/.vnc/passwd
    sudo passwd opc << END
HPC_oci1
HPC_oci1
END
    sudo x11vnc -rfbauth ~/.vnc/passwd  -auth /var/lib/gdm/:0.Xauth -display :0 -forever -bg -repeat -nowf -o ~/.vnc/x11vnc.log
    sudo x11vnc -rfbauth ~/.vnc/passwd  -auth /var/lib/gdm/:0.Xauth -display :0 -forever -bg -repeat -nowf -o ~/.vnc/x11vnc.log
fi
