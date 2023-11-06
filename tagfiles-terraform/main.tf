
provider "aws" {
  region  = "eu-central-1"
  profile = "signiance-tagifiles-tf"

  }


module "acm" {
    source = "./modules/acm"  
}

module "alb" {
    source = "./modules/alb"
  
}

module "aws_elasticache" {
  source = "./modules/aws_elasticache"
}


module "ec2" {
  source = "./modules/ec2"
}


module "ecr" {
  source = "./modules/ecr"
}

module "ecs" {
  source = "./modules/ecs"
}

module "efs" {
  source = "./modules/efs"
}

module "flowlog_iam_cloudwatch" {
  source = "./modules/flowlog_iam_cloudwatch"
}

module "openvpn_ec2" {
  source = "./modules/openvpn_ec2"
}

module "rds" {
  source = "./modules/rds"
}

module "route_53" {
  source = "./modules/route_53"
}

module "s3_buckets" {
  source = "./modules/s3_buckets"
}

module "vpc" {
  source = "./modules/vpc"
}
