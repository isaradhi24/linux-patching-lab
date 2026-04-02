#!/bin/bash
echo "========================================="
echo "Setting up Ansible Controller (Synced Version)"
echo "========================================="

# 1. Update and Install Tools
apt-get update
apt-get install -y ansible sshpass git vim tree openjdk-11-jdk

# 2. SSH Key Management (Crucial for automation)
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh

if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 2048 -f /home/vagrant/.ssh/id_rsa -N ""
    echo "SSH key generated"
fi
chmod 600 /home/vagrant/.ssh/id_rsa
chmod 644 /home/vagrant/.ssh/id_rsa.pub
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# 3. Directory Structure (Only create what doesn't exist)
# Note: /opt/ansible-lab is mounted by Vagrant, so we only need 'reports'
mkdir -p /opt/ansible-lab/reports
sudo chown -R vagrant:vagrant /opt/ansible-lab

# 4. SSH Helper Scripts (Modified to point to our new structure)
cat > /home/vagrant/distribute_keys.sh << 'EOF'
#!/bin/bash
PASSWORD="vagrant"
# Dynamically pull IPs from our synced inventory file!
NODES=$(grep "ansible_host" /opt/ansible-lab/inventory/inventory.ini | awk -F'=' '{print $2}')

for ip in $NODES; do
    echo "Copying key to $ip..."
    sshpass -p "$PASSWORD" ssh-copy-id -i /home/vagrant/.ssh/id_rsa.pub -o StrictHostKeyChecking=no vagrant@$ip
done
EOF
chmod +x /home/vagrant/distribute_keys.sh

# 5. Bash Shortcut
if ! grep -q "cd /opt/ansible-lab" /home/vagrant/.bashrc; then
    echo "cd /opt/ansible-lab" >> /home/vagrant/.bashrc
fi

# 6. Sudoers config
echo "vagrant ALL=(ALL:ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo

echo "========================================="
echo "Controller Ready! Files synced to /opt/ansible-lab"
echo "Next Step: ./distribute_keys.sh"
echo "========================================="