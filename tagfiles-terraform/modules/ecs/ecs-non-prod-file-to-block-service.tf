# Create ECS service and Task definition below.  - Non-prod Kong 

resource "aws_ecs_task_definition" "non-prod-file_to_block_service" {
  family                   = "non-prod-file_to_block_service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 512
  memory = 1024

  container_definitions = jsonencode([
    {
      name      = "non-prod-file_to_block_service"
      image     = var.file_to_block_service_image
      essential = true
      portMappings = [{
        containerPort = 5666
        hostPort      = 5666
      }],
      "mountPoints" : [{
        "sourceVolume" : "efs-file-to-block",
        "containerPath" : "/shared_volume"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-file_to_block_service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
  volume {
    name = "efs-file-to-block"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.non-prod-efs-single-az.id
      root_directory = "/"
    }
  }
}

# Security Groups

resource "aws_security_group" "non-prod-file_to_block_service-sg" {
  name        = "allow_http-file_to_block_service-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 5666
    to_port     = 5666
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
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
    Name = "non-prod-file_to_block_service-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

# data "aws_alb" "non-prod-alb-file_to_block_service" {
#     name = var.alb-name[0]
# }

# ALB Target Group

# ECS Service

resource "aws_ecs_service" "non-prod-file_to_block_service" {
  name = "non-prod-file_to_block_service"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster         = var.cluster-names[0]
  task_definition = aws_ecs_task_definition.non-prod-file_to_block_service.arn
  launch_type     = "FARGATE"
  force_new_deployment = true
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-file_to_block_service-sg.id]
    # assign_public_ip = false
  }
  depends_on = [aws_iam_role.ecs_role]

  service_registries {
    registry_arn = aws_service_discovery_service.non-prod-file-to-block-service-service-discovery.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-file_to_block_service"
    Environment = "development"
  }
}


resource "aws_service_discovery_service" "non-prod-file-to-block-service-service-discovery" {
  name = "non-prod-file-to-block-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 100
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertfile-to-blockService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-file-to-block-service-cpu-alert" {
    alarm_name                = "non-prod-file-to-block-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-file-to-block-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-file_to_block_service.name
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-file-to-block-service-memory-alert" {
    alarm_name                = "non-prod-file-to-block-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-file-to-block-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-file_to_block_service.name
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-file-to-block-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-file-to-block-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-file-to-block-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-file_to_block_service"
    }
}