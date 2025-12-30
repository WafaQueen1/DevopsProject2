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

# --- EC2 INSTANCE CONFIGURATION ---
resource "aws_instance" "my-ec2" {
  ami                    = var.ami   
  instance_type          = var.instance_type
  key_name               = var.key_name        
  
  # --- YOUR SPECIFIC SECURITY GROUP ---
  vpc_security_group_ids = ["sg-0a0665ae23d49cf8b"] 
  
  # Permission role for the instance to use AWS commands
  iam_instance_profile   = "LabInstanceProfile"

  root_block_device {
    volume_size = var.volume_size
  }
  
  tags = {
    Name = var.server_name
  }
  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      # IMPORTANT: Ensure your key file is named 'labsuser.pem' and is in this folder
      private_key = file("./labsuser.pem") 
      user        = "ubuntu"
      host        = self.public_ip
    }

    inline = [
      "sudo apt update -y",
      # Install AWS CLI
      "sudo apt install unzip -y",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      
      # Install Docker
      "sudo apt-get install -y ca-certificates curl",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc",
      "sudo chmod a+r /etc/apt/keyrings/docker.asc",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker ubuntu",
      "sudo chmod 777 /var/run/docker.sock",

      # Install Java 17 (Required for Jenkins)
      "sudo apt install openjdk-17-jdk -y",

      # Install Jenkins
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update -y",
      "sudo apt-get install -y jenkins",
      "sudo systemctl start jenkins",
      "sudo systemctl enable jenkins",
      
      # Install Kubectl
      "curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.4/2024-09-11/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl"
    ]
  }
}  

output "SERVER-SSH-ACCESS" {
  value = "ssh -i labsuser.pem ubuntu@${aws_instance.my-ec2.public_ip}"
}

output "JENKINS-URL" {
  value = "http://${aws_instance.my-ec2.public_ip}:8080"
}