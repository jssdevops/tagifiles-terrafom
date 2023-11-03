# Security Group

resource "aws_security_group" "vpn_access_server-2" {
  name        = "tf-sg-vpn-access-server-2"
  description = "Security group for VPN access server"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  tags = {
    Name = "tf-tagifiles-vpn-access-server-2"
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 943
    to_port     = 943
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance Launch

resource "aws_instance" "vpn_access_server-2" {
  ami                         = var.openvpn-ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.vpn_access_server-2.id]
  associate_public_ip_address = true
  # subnet_id                   = "${var.public_subnet_id}"
  subnet_id = aws_subnet.Non-prod-pub-a.id
  # subnet_ids = [aws_subnet.Non-prod-priv-a.id, aws_subnet.Non-prod-priv-b.id,aws_subnet.Non-prod-priv-c.id]
  # subnets            = [aws_subnet.Non-prod-pub-a.id, aws_subnet.Non-prod-pub-b.id, aws_subnet.Non-prod-pub-c.id]

  key_name = "tagifiles-open-vpn-keypair"

  tags = {
    Name = "tf-vpn-access-server"
  }
}

# Attach Elastic IP 

resource "aws_eip" "vpn_access_server-2" {
  instance = aws_instance.vpn_access_server-2.id
  domain   = "vpc"
  tags = {
    "Name" = "Non-prod-vpn-server"
  }
  
  tags_all = {
    "Name" = "Non-prod-vpn-server"
  }
}

