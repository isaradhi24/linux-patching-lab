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
                echo 'Running Pre-Patch Analysis...'
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/precheck.yml'"
            }
        }

        stage('Execute Patching') {
            steps {
                echo 'Applying System Patches...'
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/patching.yml'"
            }
        }

        stage('Post-Patch Audit') {
            steps {
                echo 'Verifying Patch Success and Generating Reports...'
                // 1. Run the dedicated Audit Playbook
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'cd /opt/ansible-lab && ansible-playbook -i inventory/inventory.ini playbooks/post-patch-audit.yml'"
                
                // 2. Prepare Local Workspace Folders
                sh "mkdir -p artifacts/pre-checks artifacts/post-audit"
                
                // 3. PULL: Sync the entire artifacts root from .10 back to Jenkins
                echo 'Syncing audit reports to Jenkins Dashboard...'
                sh "scp -o StrictHostKeyChecking=no -r vagrant@192.168.57.10:/opt/ansible-lab/artifacts/* ./artifacts/ || true"
            }
        }
    }

    post {
        always {
            echo 'Archiving Audit Proof...'
            // This grabs all .txt files from any subfolder within 'artifacts'
            archiveArtifacts artifacts: 'artifacts/**/*.txt', fingerprint: true, allowEmptyArchive: true
            
            echo 'Cleaning up Jenkins workspace...'
            deleteDir()
        }
        success {
            echo "SUCCESS: Patching cycle and reconciliation complete!"
        }
        failure {
            echo "FAILURE: Build failed. Check the 'Last Successful Artifacts' for partial reports."
        }
    }
}