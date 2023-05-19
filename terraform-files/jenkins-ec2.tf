// Create a Amazon Linux 2 EC2 instance called "Web"
resource "aws_instance" "jenkins" {
  ami = "ami-0b2d89eba83fd3ed9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.TF_jenkins_key.key_name
  security_groups = ["${aws_security_group.jenkins_SG.name}"]
  tags = {
    Name = "jenkins"
  }

// Install and start jenkins on the server
provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum upgrade",
      "sudo amazon-linux-extras install java-openjdk11 -y",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins"
    ]
  }
// Allow for Terraform to SSH into EC2 to do the above
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.rsa2.private_key_pem
    host     = self.public_ip
  }
}

// Create a AWS Key Pair
resource "aws_key_pair" "TF_jenkins_key" {
  key_name   = "TF_jenkins_key"
  public_key = tls_private_key.rsa2.public_key_openssh
}

// Create a Private Key for SSH
resource "tls_private_key" "rsa2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Store Private Key in a file for user to use to SSH themselves
resource "local_file" "TF-private_key" {
    content  = tls_private_key.rsa2.private_key_pem
    filename = "tfkey_jenkins"
    file_permission = "400"
}

// Create a security group for the EC2 instance
resource "aws_security_group" "jenkins_SG" {
  name = "jenkins_SG"
  description = "Allow HTTP, Jenkins and SSH traffic via Terraform"

  ingress {
    description = "Allow HTTP traffic via Terraform"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow Jenkins traffic via Terraform"
    from_port = 8080  
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow SSH via Terraform"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}