# Declare variables for AWS credentials
variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

provider "aws" {
  region                  = "us-east-1"  # Change this to your preferred region
  access_key             = var.aws_access_key_id
  secret_key             = var.aws_secret_access_key
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Change as necessary

  tags = {
    Name = "my-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-internet-gateway"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id  # Route all traffic to IGW
  }

  tags = {
    Name = "my-route-table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "my_route_table_assoc" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow port 80 access from anywhere 
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access on port 8081 from anywhere
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # **New Ingress Rule for Port 8020**
  # Allow access to port 8020 from anywhere
  ingress {
    from_port   = 8020
    to_port     = 8020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "my-security-group"
  }
}

# Create an EC2 instance  
resource "aws_instance" "my_instance" {
  ami                    = "ami-0866a3c8686eaeeba"  # Your specified AMI
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]  # Correct reference

  # Add public IP association
  associate_public_ip_address = true

  tags = {
    Name = "my-ec2-instance"
  }

  # Specify your key pair name for SSH access
  key_name = "nx-key"  # Use only the key pair name, no .pem extension
}

# Output the public IP of the EC2 instance
output "instance_ip" {
  value = aws_instance.my_instance.public_ip
}

# Create the inventory file in the main directory
resource "null_resource" "generate_inventory" {
  provisioner "local-exec" {
    command = <<EOF
      echo "[ec2]" > /var/jenkins_home/workspace/final-project-pipeline/inventory
      echo "ec2-instance ansible_host=${aws_instance.my_instance.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/var/jenkins_home/workspace/final-project-pipeline/nx-key.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> /var/jenkins_home/workspace/final-project-pipeline/inventory
EOF
  }
}
