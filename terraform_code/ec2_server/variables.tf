variable "instance_type" {
  default = "t3.micro" 
}

variable "ami" {
  default = "ami-0ecb62995f68bb549" # Ubuntu 24.04 LTS from User
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
  default = 10 # Reduced to 10GB to avoid lab quotas
}