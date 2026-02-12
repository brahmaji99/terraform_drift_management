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

        stage('Send Drift to Power Automate') {
            steps {
                sh '''
                jq -n \
                    --arg job "$JOB_NAME" \
                    --arg build "$BUILD_NUMBER" \
                    --arg env "prod" \
                    --arg time "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
                    --slurpfile drift drift-report.json \
                    '{
                    job_name: $job,
                    build_number: $build,
                    environment: $env,
                    timestamp: $time,
                    drift_summary: $drift[0]
                    }' > payload.json

                curl -X POST \
                    -H "Content-Type: application/json" \
                    --data @payload.json \
                    https://default189de737c93a4f5a8b686f4ca99419.12.environment.api.powerplatform.com:443/powerautomate/automations/direct/workflows/534ab24c778143bd8a7afa946eecb2f6/triggers/manual/paths/invoke?api-version=1
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
