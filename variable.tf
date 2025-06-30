# Adjust instance amount and type below based on expected traffic volume and available budget.
# More instances increase load generation capacity, but also cost!

variable "no_of_instances" {
    description = "Number of instances that is to be created by Terraform in each region"
    default     = 5 
}

variable "instance_type" {
    description = "Instance type for the Artillery nodes"
    default     = "t3.nano"
}