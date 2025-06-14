


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (official Ubuntu owner ID)
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "ci_cd" {
  name        = "ci_cd"
  description = "ci/cd managment (jenkins)"
  vpc_id      = data.aws_vpc.vpc.id

  tags = {
    project = "hannas-portfolio"
    Name = "ci_cd"
  }
}

resource "aws_vpc_security_group_ingress_rule" "jenkins" {
  security_group_id = aws_security_group.ci_cd.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ci_cd.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22 
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "https_egress" {
  security_group_id = aws_security_group.ci_cd.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 65535
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  key_name = var.key_name
  security_groups = [ aws_security_group.ci_cd.name ]

  tags = {
    project = "hannas-portfolio"
    Name = "jenkins"
  }

  user_data = file("./modules/jenkins/install_jenkins.sh")
}

# resource "null_resource" "jenkins_password" {
#   provisioner "local-exec" {
#     command = <<EOT
#       ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${var.key_path} ubuntu@${aws_instance.jenkins.public_ip} "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" > jenkins_password.txt
#     EOT
#   }

#   depends_on = [aws_instance.jenkins]
  
# }