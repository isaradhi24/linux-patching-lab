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
                // Step A: Run the patching (This stays the same)
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/patching.yml'"
                
                // Step B: NEW - Pull the files from the .10 node to the CURRENT Jenkins workspace
                // This is why Build #7 had no artifacts!
                sh "scp -o StrictHostKeyChecking=no -r vagrant@192.168.57.10:/opt/ansible-lab/artifacts ./"
            }
        }
    }
    post {
        always {
            // 1. ARCHIVE: This "uploads" the files from the workspace to the Jenkins UI
            archiveArtifacts artifacts: 'artifacts/**/*.txt', fingerprint: true, allowEmptyArchive: true
            
            // 2. CLEANUP: This wipes the /var/lib/jenkins/workspace/ folder
            echo "Cleaning up workspace to save disk space..."
            deleteDir() 
        }
        success {
            echo "Patching completed successfully and reports are ready!"
        }
        failure {
            echo "Build failed. Check the artifacts for the last known state."
        }
    }
}