terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

provider "aws" {
  region = var.region_name
}

# Security Group creation is restricted. using default SG implicitly.

# STEP2: CREATE EC2 USING PEM & SG
resource "aws_instance" "my-ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "vockey"
  subnet_id     = "subnet-0b49729e2efa05bfe"
  # vpc_security_group_ids = [aws_security_group.my-sg.id]
  iam_instance_profile = "LabInstanceProfile"

  # root_block_device removed to use AMI defaults

  tags = {
    Name = var.server_name
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo fallocate -l 2G /swapfile
              sudo chmod 600 /swapfile
              sudo mkswap /swapfile
              sudo swapon /swapfile
              echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
              
              sudo apt install unzip -y
              curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'
              unzip awscliv2.zip
              sudo ./aws/install
              
              sudo apt-get update -y
              sudo apt-get install -y ca-certificates curl
              sudo install -m 0755 -d /etc/apt/keyrings
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc
              sudo chmod a+r /etc/apt/keyrings/docker.asc
              echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
              sudo usermod -aG docker ubuntu
              sudo chmod 777 /var/run/docker.sock
              
              docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
              
              sudo apt-get install -y wget apt-transport-https gnupg
              wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
              echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee -a /etc/apt/sources.list.d/trivy.list
              sudo apt-get update -y
              sudo apt-get install trivy -y
              
              curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl
              chmod +x ./kubectl
              sudo mv ./kubectl /usr/local/bin/kubectl
              
              wget https://get.helm.sh/helm-v3.16.1-linux-amd64.tar.gz
              tar -zxvf helm-v3.16.1-linux-amd64.tar.gz
              sudo mv linux-amd64/helm /usr/local/bin/helm
              
              VERSION=$(curl -L -s https://raw.githubusercontent.com/argoproj/argo-cd/stable/VERSION)
              curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/v$VERSION/argocd-linux-amd64
              sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
              rm argocd-linux-amd64
              
              sudo apt update -y
              sudo apt install openjdk-17-jdk openjdk-17-jre -y
              
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update -y
              sudo apt-get install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

# STEP3: GET EC2 USER NAME AND PUBLIC IP 
output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

# STEP4: GET EC2 PUBLIC IP 
output "PUBLIC-IP" {
  value = aws_instance.my-ec2.public_ip
}

# STEP5: GET EC2 PRIVATE IP 
output "PRIVATE-IP" {
  value = aws_instance.my-ec2.private_ip
}
