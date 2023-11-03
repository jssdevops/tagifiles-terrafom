# Create ECS service and Task definition below.  - Non-prod Kong 

resource "aws_ecs_task_definition" "non-prod-kong_service" {
  family                   = "non-prod-kong_service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_role.arn

  #TODO move to variables here
  cpu    = 512
  memory = 1024

  container_definitions = jsonencode([
    {
      name      = "non-prod-kong_service"
      image     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/tagifiles-kong:latest"
      essential = true
      secrets   = var.kong_env_vars
      portMappings = [{
        containerPort = 8000
        hostPort      = 8000
        }, {
        containerPort = 8001
        hostPort      = 8001
        }, {
        containerPort = 8043
        hostPort      = 8043
        }, {
        containerPort = 8444
        hostPort      = 8444
      }]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/non-prod-kong_service",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

# Security Groups

resource "aws_security_group" "non-prod-kong-sg" {
  name        = "allow_http-kong"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.Non-prod-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
    # security_groups   = [aws_security_group.alb_sec_group-prod.id]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    # cidr_blocks      = 
    cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
    # security_groups   = [aws_security_group.alb_sec_group-prod.id]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "non-prod-kong-sg"
  }
}

# ALB Target Group

# Pulling ALB as data

data "aws_alb" "Non-prod-alb-kong" {
  name = var.alb-name[0]
}

# ALB Target Group

resource "aws_alb_target_group" "non-prod-kong_service-alb-tg" {
  name        = "non-prod-kong-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.Non-prod-vpc.id
  target_type = "ip"
  depends_on  = [data.aws_alb.Non-prod-alb-kong]
}

// Kong Listener

resource "aws_alb_listener_rule" "kong-listener" {
  listener_arn = aws_alb_listener.non-prod-alb-listener-ssl.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.non-prod-kong_service-alb-tg.arn
  }

  condition {
    host_header {
      values = ["kong.tagifiles.io"]
    }
  }

}


# ECS Service

resource "aws_ecs_service" "non-prod-kong" {
  name = "non-prod-kong"
  #for_each = aws_ecs_cluster.ecs-cluster
  cluster                           = var.cluster-names[0]
  task_definition                   = aws_ecs_task_definition.non-prod-kong_service.arn
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 30

  force_new_deployment = true
  desired_count = 1

  network_configuration {
    subnets = [aws_subnet.Non-prod-priv-a.id
      # ,aws_subnet.Non-prod-priv-b.id,
      # aws_subnet.Non-prod-priv-c.id
    ]
    security_groups = [aws_security_group.non-prod-kong-sg.id]
    # assign_public_ip = true
  }
  depends_on = [aws_iam_role.ecs_role, data.aws_alb.Non-prod-alb-kong]

  service_registries {
    registry_arn = aws_service_discovery_service.local-non-prod-kong-service-discovery.arn
  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.non-prod-kong_service-alb-tg.arn
    container_name   = "non-prod-kong_service"
    container_port   = 8000
  }

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
  tags = {
    Name        = "non-prod-kong_service"
    Environment = "development"
  }

}

resource "aws_service_discovery_service" "local-non-prod-kong-service-discovery" {
  name = "non-prod-kong"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}

data "aws_sns_topic" "snsAlertKongService" {
    name = "CloudWatch_Alarms_Topic"
}

// CPU Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-kong-service-cpu-alert" {
    alarm_name                = "non-prod-kong-service-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-kong-service-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-kong"
    }
}

// Memory Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-kong-service-memory-alert" {
    alarm_name                = "non-prod-kong-service-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "MemoryUtilization"
    namespace                 = "AWS/ECS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-kong-service-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
      "ClusterName" = "Non-prod-cluster"
      "ServiceName" = "non-prod-kong"
    }
}
// Repo Pull Count Alert

resource "aws_cloudwatch_metric_alarm" "non-prod-kong-service-ecr-pullcount-alert" {
    alarm_name                = "non-prod-kong-service-ecr-pullcount-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "RepositoryPullCount"
    namespace                 = "AWS/ECR"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "5"
    alarm_description         = "non-prod-kong-service-ecr-pullcount-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "RepositoryName" = "tagifiles-kong"
    }
}