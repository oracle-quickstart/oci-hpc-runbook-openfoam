#!/bin/bash
#
# Cluster init configuration script
#

#
# wait for cloud-init completion on the bastion host
#
execution=1

if [ -n "$1" ]; then
  playbook=$1
else
  playbook="/opt/oci-hpc/playbooks/site.yml"
fi

if [ -n "$2" ]; then
  inventory=$2
else
  inventory="/etc/ansible/hosts"
fi

ssh_options="-i ~/.ssh/cluster.key -o StrictHostKeyChecking=no"

if [ -f /opt/oci-hpc/playbooks/inventory ] ; then 
  sudo mv /opt/oci-hpc/playbooks/inventory /etc/ansible/hosts
fi 

if [ -f /tmp/configure.conf ] ; then
        configure=$(cat /tmp/configure.conf)
else
        configure=true
fi

if [[ $configure != true ]] ; then
        echo "Do not configure is set. Exiting"
        exit
fi

#
# A little waiter function to make sure all the nodes are up before we start configure
#

echo "Waiting for SSH to come up"

for host in $(cat /tmp/hosts) ; do
  r=0
  echo "validating connection to: ${host}"
  while ! ssh ${ssh_options} ${host} uptime ; do

        if [[ $r -eq 30 ]] ; then
                  execution=0
                  break
        fi

          echo "Still waiting for ${host}"
          sleep 60
          r=$(($r + 1))

  done
done

# Update the forks to a 8 * threads


#
# Ansible will take care of key exchange and learning the host fingerprints, but for the first time we need
# to disable host key checking.
#

if [[ $execution -eq 1 ]] ; then
  ANSIBLE_HOST_KEY_CHECKING=False ansible --private-key ~/.ssh/cluster.key all -m setup --tree /tmp/ansible > /dev/null 2>&1
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/cluster.key $playbook -i $inventory
else

        cat <<- EOF > /tmp/motd
        At least one of the cluster nodes has been innacessible during installation. Please validate the hosts and re-run:
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --private-key ~/.ssh/cluster.key /opt/oci-hpc/playbooks/site.yml
EOF

sudo mv /tmp/motd /etc/motd

fi
