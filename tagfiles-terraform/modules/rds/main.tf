// db-instance.terraform {
  
  resource "aws_security_group" "Non-prod-database" {
    name = "non-prod-database"

    description = "RDS postgres servers (terraform-managed)"
    vpc_id      = aws_vpc.Non-prod-vpc.id

    # Only postgres in
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [aws_vpc.Non-prod-vpc.cidr_block]
    }

    # Allow all outbound traffic.
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
} 

resource "aws_db_instance" "Non-prod-database" {
    identifier             = "non-prod-database"
    instance_class         = var.db_instance_type
    allocated_storage      = var.db_storage_size
    max_allocated_storage  = 100
    engine                 = var.database_engine
    engine_version         = var.database_engine_ver
    username               = var.database_user_name
    password               = var.database_user_password
    db_subnet_group_name   = aws_db_subnet_group.non-prod-db-subnet-grp.name
    vpc_security_group_ids = [aws_security_group.Non-prod-database.id]
    publicly_accessible    = false
    allow_major_version_upgrade = true
    skip_final_snapshot    = true
    deletion_protection    = true
    backup_retention_period = 3
    apply_immediately       = true
    tags = {
        "Name" = "non-prod-rds-mysql"
    }
}

    resource "aws_db_subnet_group" "non-prod-db-subnet-grp" {
        name       = "non-prod-db-subnet-grp"
        subnet_ids = [aws_subnet.Non-prod-priv-a.id, aws_subnet.Non-prod-priv-b.id,aws_subnet.Non-prod-priv-c.id]

    tags = {
        Name = "non-prod-db-subnet-grp"
    }
}


resource "aws_cloudwatch_metric_alarm" "non-prod-database-mysql-cpu-alert" {
    alarm_name                = "non-prod-database-mysql-cpu-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "CPUUtilization"
    namespace                 = "AWS/RDS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-database-mysql-cpu-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "EngineName" = "mysql" 
        # "Name"=aws_security_group.Non-prod-database.name,
        # "Value"="non-prod-database"
    }
}

resource "aws_cloudwatch_metric_alarm" "non-prod-database-mysql-memory-alert" {
    alarm_name                = "non-prod-database-mysql-memory-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "FreeableMemory"
    namespace                 = "AWS/RDS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-database-mysql-memory-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "Name"=aws_security_group.Non-prod-database.name,
        "Value"="non-prod-database"
    }
}

resource "aws_cloudwatch_metric_alarm" "non-prod-database-mysql-read-latency-alert" {
    alarm_name                = "non-prod-database-mysql-read-latency-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "ReadLatency"
    namespace                 = "AWS/RDS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-database-mysql-read-latency-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "DBInstanceIdentifier" = "non-prod-database" 
        # "Name"=aws_security_group.Non-prod-database.name,
        # "Value"="non-prod-database"
    }
}

resource "aws_cloudwatch_metric_alarm" "non-prod-database-mysql-write-latency-alert" {
    alarm_name                = "non-prod-database-mysql-write-latency-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "WriteLatency"
    namespace                 = "AWS/RDS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-database-mysql-write-latency-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "DBInstanceIdentifier" = "non-prod-database"
        "Name"=aws_security_group.Non-prod-database.name,
        "Value"="non-prod-database"
    }
}

resource "aws_cloudwatch_metric_alarm" "non-prod-database-connections-alert" {
    alarm_name                = "non-prod-database-connections-alert"
    comparison_operator       = "GreaterThanOrEqualToThreshold"
    evaluation_periods        = "3"
    datapoints_to_alarm       = "3"
    metric_name               = "DatabaseConnections"
    namespace                 = "AWS/RDS"
    period                    = "300"
    statistic                 = "Average"
    threshold                 = "80"
    alarm_description         = "non-prod-database-mysql-connections-alert"
    alarm_actions             = [data.aws_sns_topic.snsAlert.arn]
    ok_actions                = [data.aws_sns_topic.snsAlert.arn]
    dimensions = {
        "DBInstanceIdentifier" = "non-prod-database" 
        # "Name"=aws_security_group.Non-prod-database.name,
        # "Value"="non-prod-database"
    }
}
