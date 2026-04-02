pipeline {
    agent any

    stages {
        stage('Fetch Code') {
            steps {
                echo 'Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Ansible Pre-Check') {
            steps {
                // This command tells Jenkins to SSH into the controller and run the playbook
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/precheck.yml'"
            }
        }

        stage('Execute Patching') {
            steps {
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/patching.yml'"
            }
        }
    }
}