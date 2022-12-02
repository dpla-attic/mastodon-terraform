
# STATE 
##########
# variable "bucket" {
#   description = "AWS bucket for state"
# }

# variable "dynamodb_table" {
#   description = "Dynamo DB for state"
# }
#############

variable "local_domain" {
  description = "Main domain for mastodon server"
  type        = string
}

variable "db_storage" {
  description = "Storage pool for database"
  type        = number
  default     = 100
}

variable "db_backup_retention_period" {
  description = "Retention period for backups"
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "When should backups occur"
  type        = string
  default     = "00:00-00:30"
}

variable "db_name" {
  description = "Name of database"
  type        = string
  default     = "mastodon_production"
}

variable "db_maintenance_window" {
  description = "When should maintenance occur"
  type        = string
  default     = "Sun:01:00-Sun:01:30"
}

variable "db_username" {
  description = "Username of the database account"
  type        = string
  default     = "mastodon"
}

variable "db_password" {
  description = "Password of the database account"
  type        = string
}


# variable "s3_enabled" {
#   description = "S3 enabled?"
#   type        = boolean
#   default     = false
# }

# variable "s3_bucket" {
#   description = "S3 bucket"
#   type        = string
# }

# variable "s3_alias_host" {
#   description = "S3 alias host"
#   type        = string
# }

variable "secret_key_base" {
  description = "Secret key base"
  type        = string
}

variable "otp_secret" {
  description = "OTP secret"
  type        = string
}

variable "vapid_private_key" {
  description = "VAPID private key"
  type        = string
}

variable "vapid_public_key" {
  description = "VAPID public key"
  type        = string
}

variable "ip_retention_period" {
  description = "IP retention period"
  type        = number
  default     = 31556952
}

variable "session_retention_period" {
  description = "Session retention period"
  type        = number
  default     = 31556952
}

variable "web_memory" {
  description = "Memory allocation for web processes"
  type        = number
  default     = 1024
}

variable "web_cpu" {
  description = "CPU allocation for web processes"
  type        = number
  default     = 256
}

variable "mastodon_version" {
  description = "Version of mastodon"
  type        = string
  default     = "v4.0"
}