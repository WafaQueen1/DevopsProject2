variable "instance_type" {
  default = "t3.micro" 
}

variable "ami" {
  default = "ami-0a0e5d9c7acc336f1" # Ubuntu 22.04 LTS (Quick Start)
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