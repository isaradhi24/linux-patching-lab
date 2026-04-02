#!/bin/bash
set -e
echo "=== Jenkins 2026 Installation (Ubuntu 24.04) ==="

# 1. Update and Install Java 21
apt-get update
apt-get install -y openjdk-21-jdk curl wget gnupg

# 2. Add Jenkins Repo (The 2026 Key)
mkdir -p /etc/apt/keyrings
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list

# 3. Install Jenkins
apt-get update
apt-get install -y jenkins

# 4. Create 'vijay' User & Skip Wizard
mkdir -p /var/lib/jenkins/init.groovy.d/
cat <<EOF > /var/lib/jenkins/init.groovy.d/basic-setup.groovy
import jenkins.model.*
import hudson.security.*
import jenkins.install.*
def instance = Jenkins.getInstance()
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("vijay", "42557")
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
EOF

# 5. Start and Enable
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

echo "=== Jenkins Setup Finished! ==="