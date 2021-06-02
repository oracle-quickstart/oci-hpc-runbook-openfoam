#!/bin/bash -v

# Get access to other Compute Node
sudo chmod 600 /home/opc/.ssh/id_rsa

sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --remove-interface='eno2' --zone=public 
sudo firewall-cmd --reload

if [ $2 == "True" ]
then
    sudo mkdir /mnt/nvme
    sudo mount $1:/mnt/nvme /mnt/nvme
    sudo chmod 777 /mnt/nvme
fi

if [ $3 == "True" ]
then
    sudo mkdir /mnt/fss
    sudo mount $4:/sharedFS /mnt/fss
    sudo chmod 777 /mnt/fss
fi

if [ $5 == "True" ]
then
    sudo mkdir /mnt/block
    sudo mount $1:/mnt/block /mnt/block
    sudo chmod 777 /mnt/block
fi

for i in 0 1 2 3
    do
        echo Host 10.0.$i.* | sudo tee -a ~/.ssh/config
        echo "    StrictHostKeyChecking no" | sudo tee -a ~/.ssh/config
    done

# Change the LC_CTYPE variable
echo export LC_CTYPE="en_US.UTF-8" >> ~/.bashrc