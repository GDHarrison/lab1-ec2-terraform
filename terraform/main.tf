provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "web_sg" {
  name        = "lab1-ec2-web-sg"
  description = "Allow HTTP and SSH"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # For lab only. In production, restrict this to your public IP.
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab1-ec2-web-sg"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t3.micro"
  key_name = "lab1-ec2-key"
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform-created EC2</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "lab1-terraform-web-server"
  }
}

output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}