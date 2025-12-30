variable "instance_type" {
  default = "t3.medium" # Changed to medium. Jenkins + SonarQube + Java crashes on micro.
}

variable "ami" {
  default = "ami-0e86e20dae9224db8" # Ensure this is valid for us-east-1
}

variable "key_name" {
  default = "vockey" 
}

variable "region_name" {
  default = "us-east-1"
}

variable "server_name" {
  default = "Jenkins-Server"
}

variable "volume_size" {
  default = 25 # Increased slightly for Docker images
}