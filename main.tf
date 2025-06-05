provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "jenkins_vpc2" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "jenkins_vpc2"
  }
}

# Create a Subnet
resource "aws_subnet" "jenkins_subnet2" {
  vpc_id                  = aws_vpc.jenkins_vpc2.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "jenkins_subnet2"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "jenkins_igw2" {
  vpc_id = aws_vpc.jenkins_vpc2.id
  tags = {
    Name = "jenkins_igw2"
  }
}

# Create a Route Table
resource "aws_route_table" "jenkins_rt2" {
  vpc_id = aws_vpc.jenkins_vpc2.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw2.id
  }
  tags = {
    Name = "jenkins_rt2"
  }
}

# Associate the Subnet with the Route Table
resource "aws_route_table_association" "jenkins_rt_association" {
  subnet_id      = aws_subnet.jenkins_subnet2.id
  route_table_id = aws_route_table.jenkins_rt2.id
}


# Create a Security Group
resource "aws_security_group" "jenkins_sg2" {
  name        = "jenkins_sg2"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.jenkins_vpc2.id

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
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


#9000 port for sonarqube if needed
  ingress {
    from_port   = 9000
    to_port     = 9000
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
    Name = "jenkins_sg2"
  }
}

resource "aws_instance" "the_eventor" {
  ami                    = "put your ami id here"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.jenkins_subnet2.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg2.id]
  key_name = "mykey"
  user_data = file("${path.module}/server.sh")
root_block_device {
    volume_size = 50  
    volume_type = "gp3"
    delete_on_termination = true 
  } 
  tags = {
    Name = "prac_jenkins_server"
  }
}

resource "aws_instance" "the_eventor_agent" {
  ami                    = "put your ami id here"
  instance_type          = "t3.medium" 
  subnet_id              = aws_subnet.jenkins_subnet2.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg2.id]
  key_name = "mykey"
  user_data = file("${path.module}/agent.sh")
root_block_device {
  volume_size = 50  
  volume_type = "gp3"  
  delete_on_termination = true 
  }
  tags = {
    Name = "prac_jenkins_agent"
  }
}
