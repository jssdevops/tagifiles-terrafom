# Create ECS service and Task definition below.  - Non-prod Kong 

resource "aws_ecs_task_definition" "non-prod-core_services" {
  family                   = "non-prod-core_services"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 1024
  memory = 2048

  container_definitions = jsonencode([
    {
      name      = "non-prod-core_services"
      image     = var.core_service_image
      essential = true
      secrets   = var.core_env_vars
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }],
      "mountPoints" : [{
        "sourceVolume" : "efs-core-services",
        "containerPath" : "/shared_volume"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-core_services",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }

  ])
  volume {
    name = "efs-core-services"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.non-prod-efs-single-az.id
      root_directory = "/"
    }
  }
}

# Security Groups

resource "aws_security_group" "non-prod-core_services-sg" {
  name        = "allow_http-core_services-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
    # security_groups   = [aws_security_group.alb_sec_group-prod.id]
  }

  ingress {
    description = "EFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "non-prod-core_services-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

data "aws_alb" "non-prod-alb-services" {
  name = var.alb-name[0]
}

# ALB Target Group

resource "aws_alb_target_group" "non-prod-core_services-tg" {
  name        = "non-prod-core-services-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Non-prod-vpc.id
  target_type = "ip"
  depends_on  = [data.aws_alb.non-prod-alb-services]
}

// Core services Listener

# resource "aws_alb_listener_rule" "non-prod-core_services-listener" {
#   listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
#   priority     = 102

#   action {
#     type             = "forward"
#     target_group_arn = aws_alb_target_group.non-prod-core_services-tg.arn
#   }

#   condition {
#     host_header {
#       values = ["gateway-cs.tagifiles.io"]
#     }
#   }
# }

# ECS Service

resource "aws_ecs_service" "non-prod-core_services" {
  name = "non-prod-core_services"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster                           = var.cluster-names[0]
  task_definition                   = aws_ecs_task_definition.non-prod-core_services.arn
  launch_type                       = "FARGATE"
  # health_check_grace_period_seconds = 30
  enable_execute_command            = true

  force_new_deployment = true
  desired_count = 0

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups  = [aws_security_group.non-prod-core_services-sg.id]
    assign_public_ip = false
  }
  depends_on = [aws_iam_role.ecs_role, data.aws_alb.non-prod-alb-services]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-core-service-discovery.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  # load_balancer {
  #   target_group_arn = aws_alb_target_group.non-prod-core_services-tg.arn
  #   container_name   = "non-prod-core_services"
  #   container_port   = 80
  # }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = {
    Name        = "non-prod-core_services"
    Environment = "development"
  }
}

# Service Discovery

resource "aws_service_discovery_service" "local-non-prod-core-service-discovery" {
  name = "non-prod-core-service-old"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertCoreService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-cpu-alert" {
    alarm_name                = "non-prod-core-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-core-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-core_services.name
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-memory-alert" {
    alarm_name                = "non-prod-core-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-core-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-core_services.name
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-core-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-core-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-core_services"
    }
}