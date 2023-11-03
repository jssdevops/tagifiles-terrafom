resource "aws_flow_log" "Non-prod-vpc-flowlog" {
  iam_role_arn    = aws_iam_role.Non-prod-vpc-flowlogs-iam.arn
  log_destination = aws_cloudwatch_log_group.Non-prod-vpc-flow-logs-log-group.arn
  traffic_type    = "REJECT"
  vpc_id          = aws_vpc.Non-prod-vpc.id
}

resource "aws_cloudwatch_log_group" "Non-prod-vpc-flow-logs-log-group" {
  name              = "Non-prod-vpc-flow-logs-log-group"
  retention_in_days = 14
}

resource "aws_iam_role" "Non-prod-vpc-flowlogs-iam" {
  name = "Non-prod-vpc-flowlogs-iam"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "Non-prod-vpc-flowlogs-iam-role" {
  name = "Non-prod-vpc-flowlogs-iam-role"
  role = aws_iam_role.Non-prod-vpc-flowlogs-iam.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}