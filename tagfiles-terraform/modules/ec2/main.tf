# Security Group

resource "aws_security_group" "ec2_ecs_server_sg" {
    name        = "ecs-ec2-instance-sg"
    description = "Security group for ECS EC2 Instance"
    vpc_id      = aws_vpc.Non-prod-vpc.id

    tags = {
        Name = "ec2-ecs-server"
    }

    ingress {
        protocol  = "tcp"
        from_port = 22
        to_port   = 22
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        protocol  = "tcp"
        from_port = 80
        to_port   = 80
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

resource "aws_instance" "ec2_ecs_server_launch" {
    ami                         = "ami-07bca9155e8d2dc13"
    iam_instance_profile        = "ecsEC2InstanceRole"
    instance_type               = "t3.medium"
    vpc_security_group_ids      = [aws_security_group.ec2_ecs_server_sg.id]
    associate_public_ip_address = true
    # subnet_id                   = "${var.public_subnet_id}"
    subnet_id                   = aws_subnet.Non-prod-pub-a.id
    # subnet_ids = [aws_subnet.Non-prod-priv-a.id, aws_subnet.Non-prod-priv-b.id,aws_subnet.Non-prod-priv-c.id]
    # subnets            = [aws_subnet.Non-prod-pub-a.id, aws_subnet.Non-prod-pub-b.id, aws_subnet.Non-prod-pub-c.id]

    key_name                    = "tagifiles-open-vpn-keypair"

    tags = {
        Name = "ecs-ec2-instance"
    }
}

# Attach Elastic IP 

# resource "aws_eip" "vpn_access_server" {
#     instance = aws_instance.vpn_access_server.id
#     vpc = true
# }

# output "vpn_access_server_dns" {
#     value = aws_eip.vpn_access_server.public_dns
# }