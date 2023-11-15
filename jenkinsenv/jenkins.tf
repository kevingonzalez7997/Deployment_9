provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"

}


resource "aws_instance" "jenkins" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.manager_sg.id]
  key_name = "D9"
  user_data = "${file("jenkins.sh")}"
  tags = {
    Name = "jenkins"
  }
}

resource "aws_instance" "docker_node" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.agents_sg.id]
  key_name = "D9"
  user_data = "${file("docker.sh")}"

  tags = {
    Name = "docker"
  }
}

resource "aws_instance" "eks_node" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  availability_zone = "us-east-1b"
  vpc_security_group_ids = [aws_security_group.agents_sg.id]
  user_data = "${file("eks.sh")}"
  key_name = "D9"


  tags = {
    Name = "eks"
  }
}

resource "aws_security_group" "agents_sg" {
  name        = "agents"
  description = "jenkins agents sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "manager_sg" {
  name        = "manager"
  description = "manager sg"
  
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
