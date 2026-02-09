pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
        TF_INPUT         = "false"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                  terraform init -upgrade
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                sh '''
                  terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                  terraform plan \
                    -no-color \
                    -out=tfplan
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                sh '''
                  terraform apply \
                    -auto-approve \
                    tfplan
                '''
            }
        }
    }

    post {
        success {
            echo "✅ Terraform resources provisioned successfully"
        }
        failure {
            echo "❌ Terraform apply failed"
        }
    }
}
