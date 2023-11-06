// hosted-zone

resource "aws_route53_zone" "primary" {
  name = "tagifiles.io"
 // depends_on = [ aws_alb.non-prod-alb.dns_name ]
}

resource "aws_route53_record" "openvpn" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "internal.ovpn-con.tagifiles.io"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.vpn_access_server-2.public_ip]
}

// Kong Record

resource "aws_route53_record" "kong-service-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "kong.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}

// Frontend Record

resource "aws_route53_record" "frontend-service-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}


// Choreographer Record

resource "aws_route53_record" "choreographer-service-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "tf-cgphr.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}

// Core Services Record

resource "aws_route53_record" "core-service-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "gateway-cs.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}

// Core Services Record

resource "aws_route53_record" "core-service-ec2-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "gateway-cs-ec2.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}

// Notification service

resource "aws_route53_record" "notification-service-record" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "wss-gateway.tagifiles.io"
  type    = "A"

  alias {
    name                   = aws_alb.non-prod-alb.dns_name
    zone_id                = aws_alb.non-prod-alb.zone_id
    evaluate_target_health = true
  }
}