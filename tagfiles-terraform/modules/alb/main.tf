# This file contains the loadbalancers for the accounts
# Currently we create two loadbalancers one in prod and one in non-prod
# The logical grouping is kept intact, for example any security group for the 
# load balancer will be stored here and so on.

resource "aws_s3_bucket" "alb-logs" {

  bucket = var.alb-s3-bucket-name

  tags = {
    Name = var.alb-s3-bucket-name
  }
}

resource "aws_s3_bucket_policy" "alb_to_s3_access" {
  bucket = aws_s3_bucket.alb-logs.id
  policy = data.aws_iam_policy_document.alb_access_s3.json

}

data "aws_iam_policy_document" "alb_access_s3" {

  statement {

    effect = "Allow"
    principals {

      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]


    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb-logs.arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }

  statement {

    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]

    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb-logs.arn}/*/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]

    }
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.alb-logs.arn]
  }

}

resource "aws_security_group" "alb_sec_group-prod" {
  name        = "${var.alb-name[0]}-sg"
  description = "ALB rules"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.Non-prod-alb_cidr_block]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.Non-prod-alb_cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.alb-name[0]}-SG"
  }
}

#TODO Refactor
resource "aws_alb" "non-prod-alb" {
  name               = var.alb-name[0]
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sec_group-prod.id]
  subnets            = [aws_subnet.Non-prod-pub-a.id, aws_subnet.Non-prod-pub-b.id, aws_subnet.Non-prod-pub-c.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.alb-logs.bucket
    prefix  = var.alb-log-prefix[0]
    enabled = true
  }

  tags = {
    Environment = "Non-production"
  }
  depends_on = [
    aws_s3_bucket.alb-logs
  ]
}

resource "aws_alb_target_group" "alb-dummy-tg" {
  name        = "dummy-nonprod-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.Non-prod-vpc.id
  lifecycle {
    create_before_destroy = true
  }
}

# LB Target Group


resource "aws_alb_listener" "non-prod-alb-listener" {
  load_balancer_arn = aws_alb.non-prod-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Needs certificate https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

resource "aws_alb_listener" "non-prod-alb-listener-ssl" {
  load_balancer_arn = aws_alb.non-prod-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-dummy-tg.arn
  }
}