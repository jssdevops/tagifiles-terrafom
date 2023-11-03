
//ecs-cluster

variable "cluster-names" {
  default     = ["Non-prod-cluster"]
  description = "Cluster Names"
}


// Chat-service

variable "chat_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-chats-service:latest"
  description = "Chat Service image repo"
}

variable "chat-services_env_vars" {
  default = [
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "CACHE_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}


// ecs-non-prod-config_service

variable "config_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-config_service:latest"
  description = "config Service image repo"
}

variable "config-service_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}

// ecs-non-prod-connector_service

variable "connector_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-connector_service:latest"
  description = "connector Service image repo"
}

variable "connector_services_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}

//ecs-non-prod-core_services

variable "core_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
      }, {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
      }, {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
      }, {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
      }, {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
      }, {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
      }, {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
      }, {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
      }, {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
      }, {
      "name" : "TF_OTP_JWT_SECRET",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:TF_OTP_JWT_SECRET::"
      }, {
      "name" : "FILE_THUMBNAILING_ENDPOINT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:FILE_THUMBNAILING_ENDPOINT::"
      }, {
      "name" : "FILE_TO_BLOCK_ENDPOINT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:FILE_TO_BLOCK_ENDPOINT::"
      }, {
      "name" : "AWS_ACCESS_KEY_ID",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:AWS_ACCESS_KEY_ID::"
      }, {
      "name" : "AWS_SECRET_ACCESS_KEY",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:AWS_SECRET_ACCESS_KEY::"
      }, {
      "name" : "AWS_S3_BUCKET_URL",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:AWS_S3_BUCKET_URL::"
      }, {
      "name" : "ELASTIC_APM_SERVICE_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:ELASTIC_APM_SERVICE_NAME::"
      }, {
      "name" : "ELASTIC_SECRET_TOKEN",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:ELASTIC_SECRET_TOKEN::"
      }, {
      "name" : "ELASTIC_SERVER_URL",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:ELASTIC_SERVER_URL::"
      }, {
      "name" : "EL_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:EL_HOST::"
      }, {
      "name" : "EL_PSSWD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:EL_PSSWD::"
      }, {
      "name" : "LINKEDIN_CALLBACK",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LINKEDIN_CALLBACK::"
      }, {
      "name" : "FACEBOOK_CALLBACK",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:FACEBOOK_CALLBACK::"
      }, {
      "name" : "GOOGLE_CALLBACK",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:GOOGLE_CALLBACK::"
      }, {
      "name" : "EMAIL_VERIFICATION_DOMAIN",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:EMAIL_VERIFICATION_DOMAIN::"
      }, {
      "name" : "CACHE_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:CACHE_HOST::"
    }
  ]
}


//ecs-non-prod-core_services-ec2

variable "core_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-core_services:latest"
  description = "Search Service image repo"
}

//ecs-non-prod-file-to-block-service

variable "file_to_block_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-file_to_block_service:latest"
  description = "File to block Service image repo"
}

//ecs-non-prod-frontend-service

variable "frontend_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-frontend_service:latest"
  description = "Front end Service image repo"
}

//ecs-non-prod-groups_service

variable "groups_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-groups_service:latest"
  description = "Groups Service image repo"
}

variable "groups_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}


//ecs-non-prod-kong

variable "kong_env_vars" {
  default = [
    {
      "name" : "KONG_PG_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_PG_PASSWORD::"
    },
    {
      "name" : "KONG_ADMIN_ACCESS_LOG",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_ADMIN_ACCESS_LOG::"
    },
    {
      "name" : "KONG_PROXY_ACCESS_LOG",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_PROXY_ACCESS_LOG::"
    },
    {
      "name" : "KONG_ADMIN_ERROR_LOG",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_ADMIN_ERROR_LOG::"
    },
    {
      "name" : "KONG_PG_USER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_PG_USER::"
    },
    {
      "name" : "KONG_PROXY_ERROR_LOG",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_PROXY_ERROR_LOG::"
    },
    {
      "name" : "KONG_ADMIN_LISTEN",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_ADMIN_LISTEN::"
    },
    {
      "name" : "KONG_DATABASE",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_DATABASE::"
    },
    {
      "name" : "KONG_PG_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:KONG_PG_HOST::"
    }
  ]
}


//ecs-non-prod-metadata_service

variable "metadata_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-metadata_service:latest"
  description = "Metadata Service image repo"
}

variable "metadata-service_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}


//ecs-non-prod-notification-service

variable "notification_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-notifications-service:latest"
  description = "Notification Service image repo"
}

//ecs-non-prod-roles_permissions_service

variable "roles_permission_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-roles_permissions_service:latest"
  description = "Roles permissions Service image repo"
}

variable "roles_permissions_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}


//ecs-non-prod-search

variable "search_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-search_service:latest"
  description = "Search Service image repo"
}

variable "search_env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}


//ecs-non-prod-tagifiles_choreographer

variable "choreographer_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-tagifiles_choreographer:latest"
  description = "tG Choreographer service image repo"
}


//ecs-non-prod-thumbnailing_service

variable "thumbnailing_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-thumbnailing_service:latest"
  description = "thumbnailing Service image repo"
}

//ecs-non-prod-user-auth-service

variable "user_auth_service_image" {
  default     = "738086521135.dkr.ecr.eu-central-1.amazonaws.com/non-prod-user_auth_service:latest"
  description = "User auth Service image repo"
}

variable "user-auth-env_vars" {
  default = [
    {
      "name" : "LOCAL_DEV_SERVER",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:LOCAL_DEV_SERVER::"
    },
    {
      "name" : "RDS_DB_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_DB_NAME::"
    },
    {
      "name" : "RDS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_HOST::"
    },
    {
      "name" : "RDS_PASSWORD",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PASSWORD::"
    },
    {
      "name" : "RDS_PORT",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_PORT::"
    },
    {
      "name" : "RDS_USER_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:RDS_USER_NAME::"
    },
    {
      "name" : "REDIS_HOST",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST::"
    },
    {
      "name" : "REDIS_HOST_NAME",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_HOST_NAME::"
    },
    {
      "name" : "REDIS_DB",
      "valueFrom" : "arn:aws:secretsmanager:eu-central-1:738086521135:secret:tagifiles-non-prod-secret-9DStGe:REDIS_DB::"
    }
  ]
}

