# Create ECS service and Task definition below.  - Non-prod user-auth 

resource "aws_ecs_task_definition" "non-prod-user-auth-service" {
  family                   = "non-prod-user-auth-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "non-prod-user-auth-service"
      image     = var.user_auth_service_image
      essential = true
      secrets   = var.user-auth-env_vars
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-user-auth-service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

# Security Groups

resource "aws_security_group" "non-prod-user-auth-sg" {
  name        = "allow_http-user-auth"
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
    Name = "non-prod-user-auth-sg"
  }
}

# ECS Service

resource "aws_ecs_service" "non-prod-user-auth" {
  name = "non-prod-user-auth"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster         = var.cluster-names[0]
  task_definition = aws_ecs_task_definition.non-prod-user-auth-service.arn
  launch_type     = "FARGATE"
  # health_check_grace_period_seconds = 30
  desired_count = 1
  force_new_deployment = true

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-user-auth-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role
    # ,data.aws_alb.Non-prod-alb-user-auth
  ]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-service-discovery-user-auth-service.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  # load_balancer {
  #     target_group_arn = aws_alb_target_group.non-prod-user-auth-service-alb-tg.arn
  #     container_name   = "non-prod-user-auth-service"
  #     container_port   = 80
  # }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-user-auth-service"
    Environment = "development"
  }
}

# Service Discovery

resource "aws_service_discovery_service" "local-non-prod-service-discovery-user-auth-service" {
  name = "non-prod-user-auth-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 100
      type = "A"
    }
  }
}


data "aws_sns_topic" "snsAlertUserAuthService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-user-auth-cpu-alert" {
    alarm_name                = "non-prod-user-auth-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-user-auth-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-user-auth"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-user-auth-memory-alert" {
    alarm_name                = "non-prod-user-auth-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-user-auth-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-user-auth"
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-user-auth-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-user-auth-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-user-auth-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-user_auth_service"
    }
}