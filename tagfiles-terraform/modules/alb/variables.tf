variable "alb-s3-bucket-name" {
  default     = "alb-logs-tagifiles"
  description = "S3 Bucket for loadbalancer logs"
}

variable "Non-prod-alb_cidr_block" {

  default     = "0.0.0.0/0"
  description = "ALB ingress CIDR block"
}