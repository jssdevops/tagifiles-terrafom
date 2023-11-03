variable "ecr-repository-name" {
  default     = "non-prod-tagifiles-ecr"
  description = "ECR repository Name use tags like nginx:v2.4-alpine"
}

variable "tagged-image-count" {
  default     = 20
  description = "ECR untagged image count"
}

variable "untagged-image-days" {
  default     = 14
  description = "ECR tagged image count"
}

//non-prod

variable "ECR-repository-non-prod" {
  default     = ["non-prod-core_services", "non-prod-file_to_block_service", "non-prod-thumbnailing_service", "non-prod-frontend_service", "non-prod-metadata_service", "non-prod-groups_service", "non-prod-config_service", "non-prod-connector_service", "non-prod-roles_permissions_service", "non-prod-user_auth_service", "non-prod-search_service", "non-prod-tagifiles_choreographer", "non-prod-notifications-service", "non-prod-chats-service"]
  description = "Repository Names"
}