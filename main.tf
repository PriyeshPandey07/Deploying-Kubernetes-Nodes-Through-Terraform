provider "aws" {
    region = var.region
    secret_key = ""
    access_key = ""
}


# Create a VPC
resource "aws_vpc" "kube_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "kube_vpc"
  }
}

# Create a Subnet
resource "aws_subnet" "kube_subnet" {
  vpc_id                  = aws_vpc.kube_vpc.id
  cidr_block              = "10.0.1.0/24" # Smaller CIDR block for the subnet
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone
  tags = {
    Name = "kube_subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "kube_igw" {
  vpc_id = aws_vpc.kube_vpc.id
  tags = {
    Name = "kube_igw"
  }
}

# Create a Route Table
resource "aws_route_table" "kube_rt" {
  vpc_id = aws_vpc.kube_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kube_igw.id
  }
  tags = {
    Name = "kube_rt"
  }
}

# Associate the Subnet with the Route Table
resource "aws_route_table_association" "kube_rt_association" {
  subnet_id      = aws_subnet.kube_subnet.id
  route_table_id = aws_route_table.kube_rt.id
}

# Create a Security Group
resource "aws_security_group" "kube_sg" {
  name        = "kube_sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.kube_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  } 
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "kube_sg"
  }
}

# Create a Master Node
resource "aws_instance" "kube_master" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.kube_subnet.id
  key_name      = var.key_name
  associate_public_ip_address = true
  # Use security group ID instead of name
  vpc_security_group_ids = [aws_security_group.kube_sg.id]
  root_block_device {
  volume_size = 40  # Specify the desired root volume size here
  volume_type = "gp3"  # General Purpose SSD
  delete_on_termination = true  # Delete the volume when the instance is terminated
  }
  
  user_data = file("master.sh")
  tags = {
      Name = "kube_master"
    }
} 

# Create a Worker Node
resource "aws_instance" "kube_worker" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.kube_subnet.id
  key_name = var.key_name
  # Use security group ID instead of name
  vpc_security_group_ids = [aws_security_group.kube_sg.id]
  root_block_device {
  volume_size = 40  # Specify the desired root volume size here
  volume_type = "gp3"  # General Purpose SSD
  delete_on_termination = true  # Delete the volume when the instance is terminated
  }
  user_data = templatefile("worker.sh.tpl", { master_ip = aws_instance.kube_master.private_ip })
  depends_on = [ aws_instance.kube_master ]
    
  tags = {
    Name = "kube_worker"
  }
 }






    
