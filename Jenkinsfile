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
                // 1. Run Playbook
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/patching.yml'"
                
                // 2. Create the local directory in Jenkins Workspace first
                sh "mkdir -p artifacts"
                
                // 3. Pull the files (Using the absolute path to be safe)
                sh "scp -o StrictHostKeyChecking=no -r vagrant@192.168.57.10:/opt/ansible-lab/artifacts/* ./artifacts/"
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