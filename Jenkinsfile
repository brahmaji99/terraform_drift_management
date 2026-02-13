pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'eu-north-1'
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                terraform plan -out=tfplan
                terraform show -json tfplan > drift-summary.json
                '''
            }
        }

        stage('Analyze Drift with Bedrock') {
            steps {
                sh '''
                aws lambda invoke \
                  --function-name terraform-drift-bedrock-analyzer \
                  --payload file://drift-summary.json \
                  --cli-binary-format raw-in-base64-out \
                  bedrock-response.json

                jq -r '.analysis.output.message.content[0].text' \
                  bedrock-response.json > drift-ai-report.txt

                cat drift-ai-report.txt
                '''
            }
        }

        stage('Evaluate Risk') {
            steps {
                script {
                    def risk = sh(
                        script: "jq -r '.analysis.output.message.content[0].text' bedrock-response.json | grep -i 'Risk Level'",
                        returnStdout: true
                    ).trim()

                    if (risk.contains("HIGH")) {
                        error("❌ HIGH risk detected. Stopping pipeline.")
                    }

                    if (risk.contains("MEDIUM")) {
                        input message: "⚠️ MEDIUM risk detected. Approve to continue?"
                    }

                    echo "✅ Risk acceptable. Proceeding..."
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }

    post {
        success {
            echo "✅ Infrastructure successfully updated."
        }
        failure {
            echo "❌ Pipeline failed due to high risk or error."
        }
    }
}
