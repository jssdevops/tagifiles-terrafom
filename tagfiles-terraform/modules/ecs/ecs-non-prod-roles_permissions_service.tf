# Create ECS service and Task definition below.  - Non-prod roles-permissions 

resource "aws_ecs_task_definition" "non-prod-roles-permissions-service" {
  family                   = "non-prod-roles-permissions-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 256
  memory = 512

  container_definitions = jsonencode([
    {
      name      = "non-prod-roles-permissions-service"
      image     = var.roles_permission_service_image
      essential = true
      secrets   = var.roles_permissions_env_vars
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-roles-permissions-service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

# Security Groups

resource "aws_security_group" "non-prod-roles-permissions-sg" {
  name        = "allow_http-roles-permissions"
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
    Name = "non-prod-roles-permissions-sg"
  }
}

# ECS Service

resource "aws_ecs_service" "non-prod-roles-permissions" {
  name = "non-prod-roles-permissions"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster         = var.cluster-names[0]
  task_definition = aws_ecs_task_definition.non-prod-roles-permissions-service.arn
  launch_type     = "FARGATE"
  # health_check_grace_period_seconds = 30

  force_new_deployment = true
  desired_count = 0

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-roles-permissions-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role
    # ,data.aws_alb.Non-prod-alb-roles-permissions
  ]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-service-discovery-roles-permissions-service.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  # load_balancer {
  #     target_group_arn = aws_alb_target_group.non-prod-roles-permissions-service-alb-tg.arn
  #     container_name   = "non-prod-roles-permissions-service"
  #     container_port   = 80
  # }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-roles-permissions-service"
    Environment = "development"
  }

}

# Service Discovery

resource "aws_service_discovery_service" "local-non-prod-service-discovery-roles-permissions-service" {
  name = "non-prod-roles-permissions-service"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 100
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertRolesPermissionsService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-roles-permissions-service-cpu-alert" {
    alarm_name                = "non-prod-roles-permissions-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-roles-permissions-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-roles-permissions"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-roles-permissions-service-memory-alert" {
    alarm_name                = "non-prod-roles-permissions-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-roles-permissions-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-roles-permissions"
    }
}
// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-roles-permissions-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-roles-permissions-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-roles-permissions-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "non-prod-roles_permissions_service"
    }
}