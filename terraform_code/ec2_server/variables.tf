variable "instance_type" {
  default = "t3.micro" 
}

variable "ami" {
  default = "ami-0c398cb65a93047f2" # Ubuntu 22.04 LTS from User Screenshot
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