pipeline {
    agent any

    stages {
        
        stage('Ansible Pre-Check') {
            steps {
                // This command tells Jenkins to SSH into the controller and run the playbook
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/precheck.yml'"
            }
        }

        stage('Execute Patching') {
            steps {
                // 1. Run Patching
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/patching.yml'"
                
                // 2. Run Audit
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/post-patch-audit.yml'"
                
                // 3. PULL: Note the path change to the root artifacts folder
                sh "mkdir -p artifacts/post-audit"
                sh "scp -o StrictHostKeyChecking=no -r vagrant@192.168.57.10:/opt/ansible-lab/artifacts/* ./artifacts/ || true"
            }
        }
    }
    post {
        always {
            // This will now look in the root /artifacts/ folder and grab everything in subfolders
            archiveArtifacts artifacts: 'artifacts/**/*.txt', fingerprint: true, allowEmptyArchive: true
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