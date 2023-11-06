# Service Discovery

resource "aws_service_discovery_private_dns_namespace" "local-non-prod-service-discovery-ns" {
  name = "local-non-prod-service-discovery-ns"
  vpc  = aws_vpc.Non-prod-vpc.id
}

resource "aws_service_discovery_service" "local-non-prod-service-discovery" {
  name = "local-non-prod-service-discovery"
  dns_config {
    namespace_id   = aws_service_discovery_private_dns_namespace.local-non-prod-service-discovery-ns.id
    routing_policy = "MULTIVALUE"
    dns_records {
      ttl  = 300
      type = "A"
    }
  }
}