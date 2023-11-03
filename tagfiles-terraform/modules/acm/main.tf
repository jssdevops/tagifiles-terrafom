resource "aws_acm_certificate" "cert" {
  domain_name               = "tagifiles.io"
  subject_alternative_names = ["*.tagifiles.io"]
  validation_method         = "DNS"

  tags = {
    Environment = "Tagifiles ACM"
  }
}