# DEFINE DEFAULT VARIABLES HERE
# (Updated for AWS Academy Learner Lab compatibility – Dec 2025)

variable "instance_type" {
  description = "EC2 Instance Type (use t3.micro for free tier / low cost)"
  type        = string
  default     = "t3.micro"      # Recommended – cheap & sufficient
}

variable "ami" {
  description = "AMI ID – Ubuntu 22.04 LTS in us-east-1"
  type        = string
  default     = "ami-0e86e20dae9224db8"  # Official Canonical Ubuntu 22.04 LTS
}

variable "key_name" {
  description = "Key Pair Name – MUST be vockey in Learner Lab"
  type        = string
  default     = "vockey"        # The only key pair available in your lab
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20              # Reasonable default for lab
}

variable "region_name" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"     # Your lab region
}

variable "server_name" {
  description = "EC2 Server Name"
  type        = string
}


