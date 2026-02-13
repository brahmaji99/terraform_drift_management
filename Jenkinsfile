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
                sh 'terraform init -upgrade'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Drift Check') {
            steps {
                sh '''
                echo "🔍 Checking for Terraform drift..."

                set +e
                terraform plan -detailed-exitcode -no-color -out=tfdriftplan
                EXIT_CODE=$?
                set -e

                terraform show -json tfdriftplan > drift.json

                if [ "$EXIT_CODE" -eq 2 ]; then
                  echo "⚠️ Drift detected"
                  echo "DRIFT_DETECTED=true" > drift.env
                elif [ "$EXIT_CODE" -eq 0 ]; then
                  echo "✅ No drift detected"
                  echo "DRIFT_DETECTED=false" > drift.env
                else
                  echo "❌ Terraform error"
                  exit $EXIT_CODE
                fi
                '''
            }
        }

        stage('Generate Drift Summary JSON') {
            steps {
                sh '''
                DRIFT=$(grep DRIFT_DETECTED drift.env | cut -d= -f2)

                cat drift.json | jq --arg drift "$DRIFT" '{
                  job_name: "terraform-nightly-drift",
                  environment: "dev",
                  drift_detected: ($drift == "true"),
                  summary: {
                    add: ([.resource_changes[] | select(.change.actions | index("create"))] | length),
                    change: ([.resource_changes[] | select(.change.actions | index("update"))] | length),
                    destroy: ([.resource_changes[] | select(.change.actions | index("delete"))] | length)
                  },
                  resources: (if .resource_changes then [.resource_changes[] | {
                    address: .address,
                    type: .type,
                    actions: .change.actions
                  }] else [] end)
                }' > drift-summary.json
                '''
            }
        }

        stage('Analyze Drift with Bedrock (Lambda)') {
            when {
                expression { readFile('drift.env').trim() == 'DRIFT_DETECTED=true' }
            }
            steps {
                sh '''
                echo "🤖 Sending drift JSON to Amazon Bedrock via Lambda..."
                aws lambda invoke \
                --function-name terraform-drift-bedrock-analyzer \
                --payload file://drift-summary.json \
                --cli-binary-format raw-in-base64-out \
                bedrock-response.json

                echo "📄 Bedrock response:"
                cat bedrock-response.json
                '''
            }

        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'drift.json, drift-summary.json, bedrock-response.json', fingerprint: true
            echo "🔹 Terraform drift analysis completed."
        }
        success {
            echo "✅ Pipeline completed successfully."
        }
        failure {
            echo "❌ Pipeline failed."
        }
    }
}
