# Create ECS service and Task definition below.  - Non-prod thumbnailing_service

resource "aws_ecs_task_definition" "non-prod-thumbnailing_service" {
  family                   = "non-prod-thumbnailing_service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 1024
  memory = 2048

  container_definitions = jsonencode([
    {
      name      = "non-prod-thumbnailing_service"
      image     = var.thumbnailing_service_image
      essential = true
      portMappings = [{
        containerPort = 4502
        hostPort      = 4502
      }],
      "mountPoints" : [{
        "sourceVolume" : "efs-thumbnail-service",
        "containerPath" : "/shared_volume"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-thumbnailing_service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  volume {
    name = "efs-thumbnail-service"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.non-prod-efs-single-az.id
      root_directory = "/"
    }
  }
}

# Security Groups

resource "aws_security_group" "non-prod-thumbnailing_service-sg" {
  name        = "allow_http-thumbnailing_service"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 4502
    to_port     = 4502
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  #    ingress {
  #        description      = "TLS from VPC"
  #        from_port        = 2049
  #        to_port          = 2049
  #        protocol         = "tcp"
  #        cidr_blocks      = ["10.0.0.0/16"]
  #    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "non-prod-thumbnailing_service-sg"
  }
}

# ECS Service

resource "aws_ecs_service" "non-prod-thumbnailing_service" {
  name            = "non-prod-thumbnailing_service"
  cluster         = var.cluster-names[0]
  task_definition = aws_ecs_task_definition.non-prod-thumbnailing_service.arn
  launch_type     = "FARGATE"
  # health_check_grace_period_seconds = 30

  force_new_deployment = true
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-thumbnailing_service-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role
    # ,aws_alb.non-prod-thumbnailing-service
  ]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-service-discovery-thumbnailing-service.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  # load_balancer {
  #     target_group_arn = aws_alb_target_group.non-prod-thumbnailing_service-alb-tg.arn
  #     container_name   = "non-prod-thumbnailing_service"
  #     container_port   = 4502
  # }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-thumbnailing_service"
    Environment = "development"
  }
}

# Service Discovery

resource "aws_service_discovery_service" "local-non-prod-service-discovery-thumbnailing-service" {
  name = "non-prod-thumbnailing-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 100
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertThumbnailingService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-thumbnailing-service-cpu-alert" {
    alarm_name                = "non-prod-thumbnailing-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-thumbnailing-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-thumbnailing_service"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-thumbnailing-service-memory-alert" {
    alarm_name                = "non-prod-thumbnailing-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-thumbnailing-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "ClusterName" = "Non-prod-cluster"
        "ServiceName" = "non-prod-thumbnailing_service"
    }
}
// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-thumbnailing-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-thumbnailing-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-thumbnailing-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-thumbnailing_service"
    }
}