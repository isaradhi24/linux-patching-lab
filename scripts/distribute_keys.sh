#!/bin/bash
echo "Distributing SSH keys to all active nodes..."
echo "=========================================="

PASSWORD="vagrant"

# This grabs only the IP addresses from your inventory
NODES=$(grep "ansible_host=" /opt/ansible-lab/inventory/inventory.ini | sed 's/.*ansible_host=\([0-9.]*\).*/\1/')

for ip in $NODES; do
    echo "------------------------------------------"
    echo "Targeting IP: $ip"
    
    # Ping check to avoid waiting for dead VMs
    if ping -c 1 -W 1 "$ip" > /dev/null; then
        # The -o StrictHostKeyChecking=no tells SSH to trust the host automatically
        # sshpass provides the password 'vagrant' so you don't have to type it
        sshpass -p "$PASSWORD" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "vagrant@$ip"
    else
        echo "SKIPPING: Host $ip is not reachable."
    fi
done

echo "=========================================="
echo "Key distribution complete."