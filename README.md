#create dockerfile to spin up jenkins
# Use official Jenkins LTS image as base
FROM jenkins/jenkins:lts

# Switch to root to install packages
USER root

# Install dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    curl \
    jq \
    zip \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install latest AWS CLI v2 (Bedrock support)
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" \
    && unzip /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install --update \
    && rm -rf /tmp/awscliv2.zip /tmp/aws

# Install Terraform
ARG TERRAFORM_VERSION=1.6.1
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o /tmp/terraform.zip \
    && unzip /tmp/terraform.zip -d /usr/local/bin \
    && rm -rf /tmp/terraform.zip

# Switch back to Jenkins user
USER jenkins




Note: Run the following commands to run jenkins
docker build -t jenkins-terraform-bedrock .
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-aws-terraform-bedrock


# Verify installations (optional)
RUN aws --version && jq --version && zip --version && terraform --version
