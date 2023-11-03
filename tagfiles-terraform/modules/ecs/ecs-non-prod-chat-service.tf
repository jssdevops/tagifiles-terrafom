# Create ECS service and Task definition below.  - Non-prod connector service 

resource "aws_ecs_task_definition" "non-prod-chat-service" {
  family                   = "non-prod-chat-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "non-prod-chat-service"
      image     = var.chat_service_image
      essential = true
      secrets   = var.chat-services_env_vars
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-chat-service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

# Security Groups

resource "aws_security_group" "non-prod-chat-service-sg" {
  name        = "allow_http-chat-service-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
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
    Name = "non-prod-chat-service-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

# data "aws_alb" "non-prod-alb-connector-services" {
#     name = var.alb-name[0]
# }

# # ALB Target Group

# resource "aws_alb_target_group" "non-prod-chat-service-tg" {
#     name        = "non-prod-connector-service-tg"
#     port        = 80
#     protocol    = "HTTP"
#     vpc_id      = aws_vpc.Non-prod-vpc.id
#     target_type = "ip"
#     depends_on = [data.aws_alb.non-prod-alb-connector-services]
# }

# // connector service Listener

# resource "aws_alb_listener_rule" "non-prod-chat-service-listener" {
#     listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
#     priority     = 104

#     action {
#         type             = "forward"
#         target_group_arn = aws_alb_target_group.non-prod-chat-service-tg.arn
#     }

#     condition {
#         path_pattern {
#             values = ["/"]
#         }
#     }
# }

# ECS Service

resource "aws_ecs_service" "non-prod-chat-service" {
  name = "non-prod-chat-service"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster         = var.cluster-names[0]
  task_definition = aws_ecs_task_definition.non-prod-chat-service.arn
  launch_type     = "FARGATE"
  # health_check_grace_period_seconds = 30
  desired_count = 1
  force_new_deployment = true

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-chat-service-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-service-discovery-chat-service.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  # load_balancer {
  #     target_group_arn = aws_alb_target_group.non-prod-chat-service-tg.arn
  #     container_name   = "non-prod-chat-service"
  #     container_port   = 80
  # }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-chat-service"
    Environment = "development"
  }
}

resource "aws_service_discovery_service" "local-non-prod-service-discovery-chat-service" {
  name = "non-prod-chat-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 100
      type = "A"
    }
  }
}

# Pulling SNS as data

data "aws_sns_topic" "snsAlert" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-chat-service-cpu-alert" {
    alarm_name                = "non-prod-chat-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-chat-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-chat-service"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-chat-service-memory-alert" {
    alarm_name                = "non-prod-chat-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-chat-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-chat-service"
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-chat-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-chat-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-chat-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-chats-service"
    }
}