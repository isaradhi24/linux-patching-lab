pipeline {
    agent any
    stages {
        stage('Audit & Pre-Check') {
            steps {
                echo 'Running Global Infrastructure Audit...'
                // Run the playbook with the inventory flag
                sh "ssh -o StrictHostKeyChecking=no vagrant@192.168.57.10 'ansible-playbook -i /opt/ansible-lab/inventory/inventory.ini /opt/ansible-lab/playbooks/precheck.yml'"
            }
        }
        stage('Archive Evidence') {
            steps {
                echo 'Collecting Audit Reports...'
                sh "scp vagrant@192.168.57.10:/opt/ansible-lab/reports/*.txt ."
                archiveArtifacts artifacts: '*.txt', allowEmptyArchive: false
            }
        }
    }
    post {
        success {
            echo '✅ Compliance Audit Complete. Reports are attached to the build.'
        }
    }
}