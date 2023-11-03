# Create ECS service and Task definition below.  - Non-prod frontend-service 

resource "aws_ecs_task_definition" "non-prod-frontend-service" {
  family                   = "non-prod-frontend-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "non-prod-frontend-service"
      image     = var.frontend_service_image
      essential = true
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-frontend-service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

# Security Groups

resource "aws_security_group" "non-prod-frontend-service-sg" {
  name        = "allow_http-frontend-service"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description     = "TLS from VPC"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sec_group-prod.id]
    cidr_blocks     = [aws_vpc.Non-prod-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "non-prod-frontend-service-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

data "aws_alb" "Non-prod-alb-frontend-service" {
  name = var.alb-name[0]
}

# ALB Target Group

resource "aws_alb_target_group" "non-prod-frontend-service-alb-tg" {
  name        = "non-prod-frontend-service-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Non-prod-vpc.id
  target_type = "ip"
  depends_on  = [data.aws_alb.Non-prod-alb-frontend-service]
}

// frontend-service Listener

resource "aws_alb_listener_rule" "frontend-service-listener" {
  listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
  priority     = 109

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.non-prod-frontend-service-alb-tg.arn
  }

  condition {
    host_header {
      values = ["www.tagifiles.io"]
    }
  }
}

resource "aws_alb_listener_rule" "frontend-service-non-www-listener" {
  listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
  priority     = 110

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.non-prod-frontend-service-alb-tg.arn
  }

  condition {
    host_header {
      values = ["tagifiles.io"]
    }
  }
}

resource "aws_alb_listener_rule" "frontend-service-client-subdomain-listener" {
  listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
  priority     = 125

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.non-prod-frontend-service-alb-tg.arn
  }

  condition {
    host_header {
      values = ["*.tagifiles.io"]
    }
  }
}

# ECS Service

resource "aws_ecs_service" "non-prod-frontend-service" {
  name = "non-prod-frontend-service"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster                           = var.cluster-names[0]
  task_definition                   = aws_ecs_task_definition.non-prod-frontend-service.arn
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 30

  force_new_deployment = true
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-frontend-service-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role, data.aws_alb.Non-prod-alb-frontend-service]

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.non-prod-frontend-service-alb-tg.arn
    container_name   = "non-prod-frontend-service"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-frontend-service"
    Environment = "development"
  }
}

data "aws_sns_topic" "snsAlertFrontendService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-frontend-service-cpu-alert" {
    alarm_name                = "non-prod-frontend-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-frontend-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-frontend-service"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-frontend-service-memory-alert" {
    alarm_name                = "non-prod-frontend-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-frontend-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-frontend-service"
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-frontend-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-frontend-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-frontend-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-frontend_service"
    }
}