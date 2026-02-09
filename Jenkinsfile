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

        // ✅ Drift Check BEFORE Apply
       stage('Terraform Drift Check') {
            steps {
                sh '''
                echo "🔍 Checking for drift..."

                terraform plan -detailed-exitcode -no-color -out=tfdriftplan
                exit_code=$?

                terraform show -json tfdriftplan > drift-report.json

                if [ "$exit_code" -eq 2 ]; then
                    echo "⚠️ Drift detected! Blocking apply."
                    exit 1
                elif [ "$exit_code" -eq 0 ]; then
                    echo "✅ No drift detected"
                else
                    echo "❌ Terraform error"
                    exit $exit_code
                fi
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
