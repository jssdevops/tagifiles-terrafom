resource "aws_ecs_cluster" "ecs-cluster" {
  #name = var.non-prod-cluster
  for_each = toset(var.cluster-names)

  name = each.key

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

#   # Create ECS service and Task definition below.


#   resource "aws_ecs_task_definition" "non-prod-task-definition" {
#     family                   = var.ecs_task_definition_name
#     requires_compatibilities = ["FARGATE"]
#     network_mode             = "awsvpc"
#     # task_role_arn            = aws_iam_role.ecsTaskRole.arn
#     # execution_role_arn       = aws_iam_role.AmazonECSTaskExecutionRolePolicy.arn
#     execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

#     #TODO move to variables here
#     cpu    = var.ecs_task_cpu
#     memory = var.ecs_task_memory

#     container_definitions = jsonencode([
#       {
#         cpu       = var.ecs_container_cpu
#         name      = var.ecs-container-name
#         memory    = var.ecs_container_memory
#         image     = var.ecs-container-image
#         essential = true
#         portMappings = [
#           {
#             containerPort = 80
#             hostPort      = 80
#           }
#         ],
#         "logConfiguration": {
#           "logDriver": "awslogs",
#           "options": {
#             "awslogs-group": "${var.ecs_task_definition_name}-ecs-non-prod-log-group",
#             "awslogs-region": "eu-central-1",
#             "awslogs-stream-prefix": "ecs"
#           }
#         }
#       }
#     ])

#     volume {
#       name = "non-prod-efs"
#       efs_volume_configuration {
#         file_system_id =  aws_efs_file_system.non-prod-efs.id
#         root_directory = "/"
#       }
#     }
#   }

#   resource "aws_iam_role" "ecs_role" {
#   name = "ecsTaskRole"

#   # Terraform's "jsonencode" function converts a
#   # Terraform expression result to valid JSON syntax.
#   assume_role_policy = jsonencode({
#     Version = "2008-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     description = "Cluster assume role"
#   }
# }

# data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# resource "aws_iam_role_policy_attachment" "ecs-task-execution-policy-attach" {
#   role       = aws_iam_role.ecs_role.id
#   policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn

# }


# locals {
#   tvpc_ids = {
#     non-prod = aws_vpc.Non-prod-vpc
#   }
# }

#   # resource "aws_security_group" "ecs_sec_group" {
#   #   name        = "http-${each.key}"
#   #   description = "Allow http inbound traffic"
#   #   #for_each = toset(var.vpc_names)
#   #   for_each = local.tvpc_ids

#   #   #TODO switch to loadbalancer here
#   #   #vpc_id      = aws_vpc.Prod-vpc.id
#   #   vpc_id = each.value.id
#   #   ingress {
#   #     description = "TLS from VPC"
#   #     from_port   = 80
#   #     to_port     = 80
#   #     protocol    = "tcp"
#   #     #cidr_blocks      = ["aws_vpc.${each.value.cidr_block}","aws_vpc.${each.value.cidr_block}"]

#   #     cidr_blocks = ["0.0.0.0/0"]
#   #   }

#   #   egress {
#   #     from_port   = 0
#   #     to_port     = 0
#   #     protocol    = "-1"
#   #     cidr_blocks = ["0.0.0.0/0"]
#   #   }

#   #   tags = {
#   #     Name = "${each.key}-http"
#   #   }

#   # }


#   resource "aws_security_group" "ecs_sec_group_nonprod" {
#   name        = "allow_http"
#   description = "Allow http inbound traffic"
#   #for_each = toset(var.vpc_names)

#   #TODO switch to loadbalancer here
#   vpc_id      = aws_vpc.Non-prod-vpc.id 
#   #vpc_id = "aws_vpc.${each.key}.id"
#     ingress {
#       description      = "TLS from VPC"
#       from_port        = 80
#       to_port          = 80
#       protocol         = "tcp"
#       #cidr_blocks      = ["aws_vpc.${each.value.cidr_block}","aws_vpc.${each.value.cidr_block}"]

#       cidr_blocks      = ["0.0.0.0/0"]
#     }

#     egress {
#       from_port        = 0
#       to_port          = 0
#       protocol         = "-1"
#       cidr_blocks      = ["0.0.0.0/0"]
#     }
#     tags = {
#       Name = "allow_http"
#     }
#   }


# data "aws_iam_policy_document" "ecs_tasks_execution_role" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs-tasks.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "ecs_tasks_execution_role" {
#   name               = "${var.ecs_task_definition_name}-ecs-task-execution-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
# }

# resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
#   role       = aws_iam_role.ecs_tasks_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }



#   #TODO refactor the services and use for_each

#   resource "aws_ecs_service" "non-prod-service" {
#     name = var.ecs_task_definition_name
#     #for_each = aws_ecs_cluster.ecs-cluster
#     cluster         = aws_ecs_cluster.ecs-cluster[var.cluster-names[0]].id
#     task_definition = var.ecs_task_definition_name
#     launch_type     = "FARGATE"  
#     desired_count = 1
#     # deployment_circuit_breaker="enable"

#     network_configuration {
#       subnets = [aws_subnet.Non-prod-priv-a.id,
#       aws_subnet.Non-prod-priv-b.id,
#       aws_subnet.Non-prod-priv-c.id]
#       security_groups = [aws_security_group.ecs_sec_group_nonprod.id]
#       #assign_public_ip = 
#     }

#     service_registries {
#       registry_arn = aws_service_discovery_service.test-service-discovery.arn
#     }
#     deployment_circuit_breaker {
#       enable=true
#       rollback=true
#     }
#     deployment_controller {
#       type = "ECS"
#     }


#     # iam_role        = aws_iam_role.ecs_role.arn
#     # depends_on      = [aws_iam_role.ecs_role]

#     # Target Group

#     # resource "aws_lb_target_group" "nginx-tg" {
#     #   name     = "nginx-tg-lb-tg"
#     #   port     = 80
#     #   protocol = "HTTP"
#     #   vpc_id   = aws_vpc.Non-prod-vpc.id
#     # }


#     # resource "aws_vpc" "main" {
#     #   cidr_block = "10.0.0.0/16"
#     # }


#   lifecycle {
#       ignore_changes = [desired_count, task_definition]
#     }
#   }

# # resource "aws_autoscaling_group" "ecs-service-asg" {
# #   name                 = "ecs-service-asg"
# #   availability_zones   = 
# #   launch_configuration = "${aws_launch_configuration.ecs.name}"
# #   /* @todo - variablize */
# #   min_size             = 1
# #   max_size             = 10
# #   desired_capacity     = 1
# # }

# # resource "aws_appautoscaling_target" "ecs_target" {
# #   max_capacity       = 4
# #   min_capacity       = 1
# #   scalable_dimension = "ecs:service:DesiredCount"
# #   # resource_id        = "service/Non-prod-cluster/nginx-service"
# #   resource_id        = "service/${var.cluster-names[0]}/${var.ecs_task_definition_name}"
# #   service_namespace  = "ecs"
# # }

# #Automatically scale capacity up by one
# resource "aws_appautoscaling_policy" "ecs_policy_up" {
#   name               = "scale-down"
#   policy_type        = "StepScaling"
#   # resource_id        = "service/${aws_ecs_cluster.Non-prod-cluster}/${aws_ecs_service.nginx-service}"
#   resource_id        = "service/${var.cluster-names[0]}/${var.ecs_task_definition_name}"
#   # resource_id        = "service/Non-prod-cluster/nginx-service"
#   scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
#   service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

#   step_scaling_policy_configuration {
#     adjustment_type         = "ChangeInCapacity"
#     cooldown                = 60
#     metric_aggregation_type = "Maximum"

#     step_adjustment {
#       metric_interval_upper_bound = 0
#       scaling_adjustment          = -1
#     }
#   }
# }



# resource "aws_alb_target_group" "non-prod-alb-tg" {
#     name        = var.non-prod-alb-tg
#     port        = 80
#     protocol    = "TCP"
#     vpc_id      = aws_vpc.Non-prod-vpc.id
#     # depends_on = ["${aws_alb.non-prod-alb-tg}"]
# }


#   # resource "aws_alb_target_group_attachment" "test" {
#   #   target_group_arn = [var.non-prod-alb-tg].arn
#   #   # target_id        = aws_instance.non-prod-alb-tg-ecs.id
#   #   port             = 80
#   # } 


# # Logging

# resource "aws_cloudwatch_log_group" "ecs-non-prod-log-group" {
#   name = "${var.ecs_task_definition_name}-ecs-non-prod-log-group"
#   retention_in_days = 30
# }


# # Service Discovery

# resource "aws_service_discovery_private_dns_namespace" "ecs-service-discovery-nginx"{
#   name = "nginx-test-service-discovery"
#   vpc = aws_vpc.Non-prod-vpc.id
# }

# resource "aws_service_discovery_service" "test-service-discovery"{
#   name="test-service-discovery"
#   dns_config{
#     namespace_id = aws_service_discovery_private_dns_namespace.ecs-service-discovery-nginx.id
#     routing_policy = "MULTIVALUE"
#     dns_records {
#       ttl = 10
#       type= "A"
#     }
#   }
# }