#!/bin/bash -v

echo $*
# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

# Next line is needed for CentOS base Image
sudo firewall-cmd --remove-interface='eno2' --zone=public
sudo firewall-cmd --permanent --zone=public --add-source=$1
sudo firewall-cmd --reload

if [ $3 == "True" ]
then
    sudo mkdir /mnt/nvme
    sudo systemctl stop firewalld
    sudo mount $2:/mnt/nvme /mnt/nvme
fi


if [ $4 == "True" ]
then
    sudo mkdir /mnt/fss
    sudo mount $5:/sharedFS /mnt/fss
    sudo chmod 777 /mnt/fss
fi


if [ $6 == "True" ]
then
    sudo mkdir /mnt/block
    sudo mount $2:/mnt/block /mnt/block
    sudo chmod 777 /mnt/block
fi


if [ $8 == "off" ]
then
    sudo /mnt/$7/scripts/disable_ht.sh 0
fi

if [ $9 -gt 0 ]
then
    echo y | sudo mkfs -t ext4 /dev/nvme0n1
    sudo mount /dev/nvme0n1 /mnt/local
    sudo chmod 777 /mnt/local
fi

for i in 0 1 2 3
    do
        echo Host 10.0.$i.* | sudo tee -a ~/.ssh/config
        echo "    StrictHostKeyChecking no" | sudo tee -a ~/.ssh/config
    done

# Change the LC_CTYPE variable
echo export LC_CTYPE=\"en_US.UTF-8\" >> ~/.bashrc