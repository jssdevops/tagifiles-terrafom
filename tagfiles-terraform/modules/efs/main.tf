# #----------------------------------------
# # Create EFS
# #----------------------------------------

# resource "aws_efs_file_system" "non-prod-efs" {
#     creation_token = "non-prod-efs"
#     performance_mode = "generalPurpose"
#     throughput_mode = "bursting"
#     encrypted = "true"
#     tags = {
#         Name = var.non-prod-efs
#     }
# }
# resource "aws_efs_backup_policy" "policy" {
#     file_system_id = aws_efs_file_system.non-prod-efs.id

#     backup_policy {
#         status = "ENABLED"
#     }
# }

# #----------------------------------------
# # Mounting EFS
# #----------------------------------------

# resource "aws_efs_mount_target" "mount" {
#     file_system_id = aws_efs_file_system.non-prod-efs.id
#     subnet_id      = aws_subnet.Non-prod-priv-a.id
# }


#----------------------------------------
# ECS security-group
#----------------------------------------
resource "aws_security_group" "ecs_container_security_group" {

  name        = "ecs-efs-sg"
  description = "File traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




//efs single AZ


#----------------------------------------
# Create EFS
#----------------------------------------

resource "aws_efs_file_system" "non-prod-efs-single-az" {
  creation_token         = "non-prod-efs-single-az"
  performance_mode       = "generalPurpose"
  throughput_mode        = "bursting"
  encrypted              = "true"
  availability_zone_name = "eu-central-1a"

  tags = {
    Name = "non-prod-efs-single-az"
  }
}
resource "aws_efs_backup_policy" "policy-single-az" {
  file_system_id = aws_efs_file_system.non-prod-efs-single-az.id

  backup_policy {
    status = "ENABLED"
  }
}

#----------------------------------------
# Mounting EFS
#----------------------------------------

resource "aws_efs_mount_target" "mount-single-az" {
  file_system_id = aws_efs_file_system.non-prod-efs-single-az.id
  subnet_id      = aws_subnet.Non-prod-priv-a.id
}


#----------------------------------------
# ECS security-group
#----------------------------------------
resource "aws_security_group" "ecs_container_security_group-single-az" {

  name        = "ecs-efs-single-az-sg"
  description = "File traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
        