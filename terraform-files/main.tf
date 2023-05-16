// Create a Amazon Linux 2 EC2 instance called "Web"
resource "aws_instance" "web" {
  ami = "ami-0b2d89eba83fd3ed9"
  instance_type = "t2.micro"
  key_name = aws_key_pair.TF_key.key_name
  security_groups = ["${aws_security_group.web_SG.name}"]
  tags = {
    Name = "web"
  }

// Install and start nginx on the server
provisioner "remote-exec" {
    inline = [
      "sudo yum update",
      "sudo amazon-linux-extras install -y nginx1",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }
// Allow for Terraform to SSH into EC2 to do the above
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = tls_private_key.rsa.private_key_pem
    host     = self.public_ip
  }
// Store IP address so we can use this to access website
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ip_address.txt"
  }
}

// Create a AWS Key Pair
resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

// Create a Private Key for SSH
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// Store Private Key in a file for user to use to SSH themselves
resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
    file_permission = "400"
}

// Create a security group for the EC2 instance
resource "aws_security_group" "web_SG" {
  name = "web_SG"
  description = "Allow HTTP, HTTPS and SSH traffic via Terraform"

  ingress {
    description = "Allow HTTP traffic via Terraform"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Allow HTTPS traffic via Terraform"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
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

