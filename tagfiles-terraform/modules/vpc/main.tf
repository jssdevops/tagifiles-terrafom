# resource "aws_vpc" "non-Prod-vpc" {
#     cidr_block = var.non-Prod-vpc

#     tags = {
#         Name = "non-prod-vpc_"
#     }
# }

resource "aws_vpc" "Non-prod-vpc" {
  cidr_block           = var.Non-prod-vpc
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Non-prod-vpc"
  }
}

# resource "aws_vpc_peering_connection" "non-prod_and_prod-vpc-peer" {
#     peer_vpc_id   = aws_vpc.Prod-vpc.id
#     vpc_id        = aws_vpc.non-Prod-vpc.id
#     auto_accept   = true

#     tags = {
#         Name = "VPC Peering"
#     }
# }

// Internet Gateway 

resource "aws_internet_gateway" "Non-prod-igw" {
  vpc_id = aws_vpc.Non-prod-vpc.id

  tags = {
    Name = "Non-prod-igw"
  }
}

// subnets 

resource "aws_subnet" "Non-prod-pub-a" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-1
  availability_zone = var.availability-zone-1

  tags = {
    "Name" = "Non-prod-pub-a"
  }
}
resource "aws_subnet" "Non-prod-priv-a" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-2
  availability_zone = var.availability-zone-1

  tags = {
    "Name" = "Non-prod-priv-a"
  }
}
resource "aws_subnet" "Non-prod-pub-b" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-3
  availability_zone = var.availability-zone-2

  tags = {
    "Name" = "Non-prod-pub-b"
  }
}
resource "aws_subnet" "Non-prod-priv-b" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-4
  availability_zone = var.availability-zone-2

  tags = {
    "Name" = "Non-prod-priv-b"
  }
}
resource "aws_subnet" "Non-prod-pub-c" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-5
  availability_zone = var.availability-zone-3

  tags = {
    "Name" = "Non-prod-pub-c"
  }
}
resource "aws_subnet" "Non-prod-priv-c" {
  vpc_id            = aws_vpc.Non-prod-vpc.id
  cidr_block        = var.Non-prod-subnet-6
  availability_zone = var.availability-zone-3

  tags = {
    "Name" = "Non-prod-priv-c"
  }
}


