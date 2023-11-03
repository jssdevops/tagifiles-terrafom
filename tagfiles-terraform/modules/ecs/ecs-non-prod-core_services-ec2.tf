# Create ECS service and Task definition below.  - Non-prod Kong 

resource "aws_ecs_task_definition" "non-prod-core_services-ec2" {
  family                   = "non-prod-core_services-ec2"
  requires_compatibilities = ["EC2"]
#   network_mode             = "bridge"
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_agent.arn
  execution_role_arn       = aws_iam_role.ecs_agent.arn


#   #TODO move to variables here
  cpu    = 1024
  memory = 2048

  container_definitions = jsonencode([
    {
      name      = "non-prod-core_services-ec2"
      image     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/core-service-ec2:latest"
      essential = true
      secrets   = var.core_env_vars
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }],
      "mountPoints" : [{
        "sourceVolume" : "efs-core-services-ec2",
        "containerPath" : "/shared_volume"
      }],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-core_services-ec2",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }

  ])
  volume {
    name = "efs-core-services-ec2"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.non-prod-efs-single-az.id
      root_directory = "/"
    }
  }
}

# Security Groups

resource "aws_security_group" "non-prod-core_services-sg-ec2" {
  name        = "allow_http-core_services-ec2-sg"
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
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
    # security_groups   = [aws_security_group.alb_sec_group-prod.id]
  }

  # ingress {
  #   description = "EFS from VPC"
  #   from_port   = 2049
  #   to_port     = 2049
  #   protocol    = "tcp"
  #   cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "non-prod-core_services-ec2-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

data "aws_alb" "non-prod-alb-services-ec2" {
  name = var.alb-name[0]
}

# ALB Target Group

resource "aws_alb_target_group" "non-prod-core_services-tg-ec2" {
  name        = "non-prod-core-services-ec2-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Non-prod-vpc.id
  target_type = "ip"
  depends_on  = [data.aws_alb.non-prod-alb-services-ec2]
}

// Core services Listener

resource "aws_alb_listener_rule" "non-prod-core_services-listener-ec2" {
  listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
  priority     = 53

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.non-prod-core_services-tg-ec2.arn
  }

  condition {
    host_header {
      values = ["gateway-cs.tagifiles.io"]
    }
  }
}

# ECS Service

resource "aws_ecs_service" "non-prod-core_services-ec2" {
  name = "non-prod-core_services-ec2"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster                           = var.cluster-names[0]
  task_definition                   = aws_ecs_task_definition.non-prod-core_services-ec2.arn
  launch_type                       = "EC2"
  health_check_grace_period_seconds = 30
  enable_execute_command            = true
#   network_mode ="bridge"
  force_new_deployment = true
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups  = [aws_security_group.non-prod-core_services-sg-ec2.id]
    assign_public_ip = false
  }

  depends_on = [aws_iam_role.ecs_agent, data.aws_alb.non-prod-alb-services-ec2]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-core-service-discovery-ec2.arn
    # registry_arn = aws_service_discovery_service.local-non-prod-core-service-discovery-ec2.arn
    # container_port = 80
    container_name = "non-prod-core_services-ec2"
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

    ordered_placement_strategy {
          field = "attribute:ecs.availability-zone"
          type  = "spread"
        }
    ordered_placement_strategy {
          field = "instanceId"
          type  = "spread"
    }

  load_balancer {
    target_group_arn = aws_alb_target_group.non-prod-core_services-tg-ec2.arn
    container_name   = "non-prod-core_services-ec2"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  tags = {
    Name        = "non-prod-core_services-ec2"
    Environment = "development"
  }
}

# Service Discovery

resource "aws_service_discovery_service" "local-non-prod-core-service-discovery-ec2" {
  name = "non-prod-core-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertCoreServiceEC2" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-cpu-alert-ec2" {
    alarm_name                = "non-prod-core-service-cpu-alert-ec2"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-core-service-cpu-alert-ec2"
    alarm_actions             = [data.aws_sns_topic.snsAlertCoreServiceEC2.arn]
    ok_actions                = [data.aws_sns_topic.snsAlertCoreServiceEC2.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-core_services-ec2.name
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-memory-alert-ec2" {
    alarm_name                = "non-prod-core-service-memory-alert-ec2"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-core-service-memory-alert-ec2"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = aws_ecs_service.non-prod-core_services-ec2.name
    }
}

// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-core-service-ecr-pullcount-alert-ec2" {
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