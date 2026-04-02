#!/bin/bash

echo "========================================="
echo "Setting up node: $(hostname)"
echo "========================================="

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    echo "Cannot detect OS"
    exit 1
fi

# 1. Install Python and basic tools based on OS
case $OS in
    ubuntu|debian)
        echo "Detected Ubuntu/Debian system"
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y python3 python3-pip curl wget vim tree
        ;;
    rhel|centos|rocky|almalinux)
        echo "Detected RHEL-family system: $OS $VER"
        dnf install -y python3 python3-pip curl wget vim tree || yum install -y python3 python3-pip curl wget vim tree
        ;;
    opensuse-leap|suse|opensuse*)
        echo "Detected SUSE-family system"
        # SUSE needs the python3-base and python3-pip packages
        zypper refresh
        zypper install -y python3 python3-pip curl wget vim tree
        
        # SUSE Specific: Disable Firewall to let Ansible through
        systemctl stop firewalld || true
        systemctl disable firewalld || true
        ;;
    *)
        echo "Unknown OS: $OS - attempting generic python install"
        command -v dnf &>/dev/null && dnf install -y python3
        command -v apt-get &>/dev/null && apt-get install -y python3
        ;;
esac

# 2. Ensure /usr/bin/python exists (Ansible looks for this by default)
if [ ! -f /usr/bin/python ] && [ -f /usr/bin/python3 ]; then
    ln -s /usr/bin/python3 /usr/bin/python
fi

# 3. Setup SSH directory and Permissions
mkdir -p /home/vagrant/.ssh
touch /home/vagrant/.ssh/authorized_keys
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# 4. Network Persistence Fix (CRITICAL for RHEL/SUSE)
# This forces the secondary interface to stay up after the script finishes
nmcli device connect eth1 || nmcli device connect enp0s8 || true

echo "========================================="
echo "Node $(hostname) Setup Complete!"
echo "OS: $OS $VER"
echo "========================================="