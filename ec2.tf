provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "group-name"
    values = ["default"]
  }
}

resource "aws_instance" "strapi_instance" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.medium"
  key_name               = "Intern"
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name = "Strapi-Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install docker.io -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              # Create docker-compose.yml
              cat <<EOT >> /home/ubuntu/docker-compose.yml
              version: '3'
              services:
                strapi:
                  image: strapi/strapi
                  ports:
                    - "1337:1337"
                  volumes:
                    - ./app:/srv/app
              EOT

              # Run Docker Compose
              sudo docker-compose -f /home/ubuntu/docker-compose.yml up -d
              EOF
}

output "instance_ip" {
  value = aws_instance.strapi_instance.public_ip
}
