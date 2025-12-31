terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
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
  key_name      = var.key_name        
  subnet_id     = "subnet-0b49729e2efa05bfe"
  # vpc_security_group_ids = [aws_security_group.my-sg.id]
  iam_instance_profile   = "arn:aws:iam::992382414402:instance-profile/LabInstanceProfile"
  
  # root_block_device removed to use AMI defaults
  
  tags = {
    Name = var.server_name
  }
}  

# STEP3: GET EC2 USER NAME AND PUBLIC IP 
output "SERVER-SSH-ACCESS" {
  value = "ubuntu@${aws_instance.my-ec2.public_ip}"
}

# STEP4: GET EC2 PUBLIC IP 
output "PUBLIC-IP" {
  value = "${aws_instance.my-ec2.public_ip}"
}

# STEP5: GET EC2 PRIVATE IP 
output "PRIVATE-IP" {
  value = "${aws_instance.my-ec2.private_ip}"
}