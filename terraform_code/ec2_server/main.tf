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
  # Credentials are automatically picked up from your ~/.aws/credentials 
  # or environment variables (AWS_ACCESS_KEY_ID, etc.)
}

# STEP 1: GET EXISTING LAB RESOURCES (Instead of creating new ones)
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "lab_sg" {
  # We select the default security group of the VPC. 
  # In AWS Academy, this usually allows all internal traffic.
  # IF SSH fails, you may need to manually allow Port 22 on this SG in the AWS Console.
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# STEP 2: CREATE EC2 USING EXISTING RESOURCES
resource "aws_instance" "my-ec2" {
  ami                    = var.ami   
  instance_type          = var.instance_type
  key_name               = var.key_name        
  
  # CHANGE 1: Use the existing Security Group found above
  vpc_security_group_ids = [data.aws_security_group.lab_sg.id]
  
  # CHANGE 2: Attach the LabRole so Jenkins can manage AWS resources
  # "LabInstanceProfile" is the standard name in AWS Academy.
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size = var.volume_size
  }
  
  tags = {
    Name = var.server_name
  }
  
  # USING REMOTE-EXEC PROVISIONER TO INSTALL PACKAGES
  provisioner "remote-exec" {
    # ESTABLISHING SSH CONNECTION WITH EC2
    connection {
      type        = "ssh"
      private_key = file("./labsuser.pem") # IMPORTANT: Ensure this filename matches your downloaded key
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      # --- Install AWS CLI ---
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",

      # --- Install Docker ---
      "sudo apt-get update -y",
      "sudo apt-get install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo chmod 777 /var/run/docker.sock",
      
      # --- Install SonarQube ---
      "docker run -d --name sonar -p 9000:9000 sonarqube:lts-community",

      # --- Install Trivy ---
      "sudo apt-get install -y wget apt-transport-https gnupg",
      "wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null",
      "echo 'deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main' | sudo tee -a /etc/apt/sources.list.d/trivy.list",
      "sudo apt-get update -y",
      "sudo apt-get install trivy -y",

      # --- Install Kubectl ---
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH",
      "sudo mv $HOME/bin/kubectl /usr/local/bin/kubectl",
      
      # --- Install Java 17 ---
      "sudo apt update -y",
      "sudo apt install openjdk-17-jdk openjdk-17-jre -y",

      # --- Install Jenkins ---
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
    ]
  }
}  

# OUTPUTS
output "SERVER-SSH-ACCESS" {
  value = "ssh -i labsuser.pem ubuntu@${aws_instance.my-ec2.public_ip}"
}

output "JENKINS-URL" {
  value = "http://${aws_instance.my-ec2.public_ip}:8080"
}