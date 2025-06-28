variable "key_name" {
  description = "Name of the existing SSH key pair in AWS"
  default     = "ansible-key.pem"
}

variable "ami" {
    description = "AMI ID for the Artillery node instances"
    default     = "ami-020cba7c55df1f615" 
}

variable "instance_type" {
    description = "Instance type for the Artillery nodes"
    default     = "t3.nano"
}