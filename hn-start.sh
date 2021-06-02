#!/bin/bash -v

echo $*
# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

# Create share directory

sudo firewall-cmd --permanent --zone=public --add-service=nfs
# Next line is needed for CentOS base Image
sudo firewall-cmd --remove-interface='eno2' --zone=public 
sudo firewall-cmd --permanent --zone=public --add-source=$1
sudo firewall-cmd --reload

if [ $2 == "True" ]
then
    sudo mkdir /mnt/nvme
    sudo systemctl enable nfs-server.service
    sudo systemctl start nfs-server.service
    if [ ${10} -gt 0 ]
    then
        sudo yum -y install nfs-utils gdisk
        ( echo n; echo 1; echo 2048; echo +${10}G; echo 8300; echo n; echo 2;  echo ; echo ; echo 8300; echo w; echo Y; ) | sudo gdisk /dev/nvme0n1
        echo y | sudo mkfs -t ext4 /dev/nvme0n1p1
        echo y | sudo mkfs -t ext4 /dev/nvme0n1p2
        sudo mount /dev/nvme0n1p1 /mnt/local
        sudo mkdir /mnt/local
        sudo mount /dev/nvme0n1p2 /mnt/nvme
        sudo chmod 777 /mnt/local
        mkdir /mnt/local/tmp
    else
        echo y | sudo mkfs -t ext4 /dev/nvme0n1
        sudo mount /dev/nvme0n1 /mnt/nvme
    fi
    sudo chmod 777 /mnt/nvme
    echo '/mnt/nvme    10.0.0.0/16(rw)' | sudo tee -a /etc/exports
    sudo exportfs -a
fi

if [ $3 == "True" ]
then
    sudo mkdir /mnt/fss
    sudo mount $5:/sharedFS /mnt/fss
    sudo chmod 777 /mnt/fss
fi

if [ $4 == "True" ]
then
    sudo iscsiadm -m node -o new -T $6 -p $7
    sudo iscsiadm -m node -o update -T $6 -n node.startup -v automatic
    sudo iscsiadm -m node -T $6 -p $7 -l
    device=`lsblk -o KNAME,TRAN,MOUNTPOINT | grep iscsi | grep -v / | grep -v sda | awk '{ print $1}'`
    echo $device
    sleep 10
    sudo mkdir /mnt/block
    sudo systemctl enable nfs-server.service
    sudo systemctl start nfs-server.service
    echo y | sudo mkfs -t ext4 /dev/$device
    sudo mount /dev/$device /mnt/block
    sudo chmod 777 /mnt/block
    echo '/mnt/block    10.0.0.0/16(rw)' | sudo tee -a /etc/exports
    sudo exportfs -a
fi

echo /mnt/$8/scripts

sudo mkdir /mnt/$8/scripts
sudo chmod 777 /mnt/$8/scripts
sudo mkdir /mnt/$8/logs
sudo chmod 777 /mnt/$8/logs

ls -l /mnt/$8

mv ~/visualization.sh /mnt/$8/scripts
mv ~/disable_ht.sh /mnt/$8/scripts
sudo chmod 775 /mnt/$8/scripts/disable_ht.sh
sudo chmod 775 /mnt/$8/scripts/visualization.sh

# Change the LC_CTYPE variable
echo export LC_CTYPE=\"en_US.UTF-8\" >> ~/.bashrc
for i in 0 1 2 3
    do
        echo Host 10.0.$i.* | sudo tee -a ~/.ssh/config
        echo "    StrictHostKeyChecking no" | sudo tee -a ~/.ssh/config
    done

if [ $9 == "off" ]
then
    sudo /mnt/$8/scripts/disable_ht.sh 0
fi