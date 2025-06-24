variable "instance_type" {
  default = "t3.medium"
  type        = string
}

variable "region" {
  default = "ap-south-1"
  type        = string
}

variable "ami" {
  default = "" # Update with your AMI ID
  type        = string
}

variable "key_name" {
  default = "mykey"
  type        = string
}

variable "availability_zone" {
  default = "ap-south-1a"
}