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


echo "========================================="
echo "Next Step: Setting up GitHub Actions Runner"
echo "to start the runner and connect to GitHub" on ansible-controller"
echo "Token from your GitHub repo settings.
echo "Go to your GitHub Repository -> Settings -> Actions -> Runners."
echo "Click New self-hosted runner."
echo "Select Linux."
echo "Look for the section titled Configure. You will see a command that looks like ./config.sh --url ... --token ...."
echo "run ./config.sh --url https://github.com/OWNER/REPO --token YOUR_TOKEN_HERE"
echo vagrant@ansible-controller:/opt/ansible-lab/actions-runner$ ./config.sh --url https://github.com/isaradhi24/linux-patching-lab --token AENDMQJHMT3ORRPIAJBN6TTJ46QGS

# --------------------------------------------------------------------------------
# |        ____ _ _   _   _       _          _        _   _                      |
# |       / ___(_) |_| | | |_   _| |__      / \   ___| |_(_) ___  _ __  ___      |
# |      | |  _| | __| |_| | | | | '_ \    / _ \ / __| __| |/ _ \| '_ \/ __|     |
# |      | |_| | | |_|  _  | |_| | |_) |  / ___ \ (__| |_| | (_) | | | \__ \     |
# |       \____|_|\__|_| |_|\__,_|_.__/  /_/   \_\___|\__|_|\___/|_| |_|___/     |
# |                                                                              |
# |                       Self-hosted runner registration                        |
# |                                                                              |
# --------------------------------------------------------------------------------

# # Authentication
# √ Connected to GitHub
# # Runner Registration
# Enter the name of the runner group to add this runner to: [press Enter for Default]
# Enter the name of runner: [press Enter for ansible-controller] ansible-controller-runner
# This runner will have the following labels: 'self-hosted', 'Linux', 'X64'
# Enter any additional labels (ex. label-1,label-2): [press Enter to skip]
# √ Runner successfully added
# # Runner settings
# Enter name of work folder: [press Enter for _work]
# √ Settings Saved.
# vagrant@ansible-controller:/opt/ansible-lab/actions-runner$

echo " ./run.sh to start the runner and connect to GitHub"

echo "========================================="
