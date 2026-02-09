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
                  echo "🔍 Checking for drift against current state..."
                  
                  # Refresh the state
                  terraform refresh

                  # Generate a drift plan
                  terraform plan -detailed-exitcode -out=tfdriftplan -no-color || true

                  # Export drift plan to JSON
                  terraform show -json tfdriftplan > drift-report.json

                  # Check exit code to detect drift
                  drift_exit_code=$?
                  if [ "$drift_exit_code" -eq 2 ]; then
                    echo "⚠️ Drift detected! See drift-report.json for details"
                  elif [ "$drift_exit_code" -eq 0 ]; then
                    echo "✅ No drift detected"
                  else
                    echo "❌ Error during drift check"
                    exit $drift_exit_code
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
