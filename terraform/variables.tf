# Parameterized variables for the Terraform configuration

# Region 
variable "region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

# AMI 
variable "ami" {
  description = "The AMI to use for the EC2 instance"
  type        = string
  default     = "ami-011899242bb902164"
}

# Instance type
variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type        = string
  default     = "t2.micro"
}

# AWS Route53 domain
variable "domain" {
  description = "The domain to use for the Route53 hosted zone"
  type        = string
  default     = "abhishektriesdevops.com"
}

# Application Port 
variable "port" {
  description = "The port to use for the EC2 instance"
  type        = number
  default     = 8080
}

# LB Port
variable "lb_port" {
  description = "The port to use for the load balancer"
  type        = number
  default     = 80
}