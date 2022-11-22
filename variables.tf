
# STATE 
##########
# variable "bucket" {
#   description = "AWS bucket for state"
# }

# variable "dynamodb_table" {
#   description = "Dynamo DB for state"
# }
#############

variable "region" {
  description = "AWS region (e.g. us-east-1)"
  type        = string
}

variable "local_domain" {
  description = "Main domain for mastodon server"
  type        = string
}


# variable "app_port" {
#   description = "Container application port"
#   type        = number
#   default     = 8080
# }

// sensitive data from secrets.tfvars

# variable "redis_host" {
#   description = "Redis host"
#   type        = string
# }

# variable "redis_port" {
#   description = "Redis port"
#   type        = number
#   default     = 6379
# }

# variable "db_host" {
#   description = "Postgresql host"
#   type        = string
# }

# variable "db_user" {
#   description = "Postgresql user"
#   type        = string
# }

# variable "db_name" {
#   description = "Postgresql database name"
#   type        = string
# }

# variable "db_pass" {
#   description = "Postgresql password"
#   type        = string
# }

# variable "db_port" {
#   description = "Postgresql port"
#   type        = nnumber
#   default     = 5432
# }

# variable "es_enabled" {
#   description = "Elasticsearch enabled?"
#   type        = boolean
#   default     = false
# }

# variable "es_host" {
#   description = "Elasticsearch host"
#   type        = string
# }

# variable "es_port" {
#   description = "Elastiscearch port"
#   type        = number
#   default     = 9200
# }

# variable "es_user" {
#   description = "Elasticsearch user"
#   type        = string
# }

# variable "es_pass" {
#   description = "Elasticsearch password"
#   type        = string
# }

# variable "secret_key_base" {
#   description = "Mastodon secret key base"
#   type        = string
# }

# variable "otp_secret" {
#   description = "Mastodon OTP secret"
#   type        = string
# }

# variable "vapid_private_key" {
#   description = "Mastodon vapid private key"
#   type        = string
# }

# variable "vapid_public_key" {
#   description = "Mastodon vapid public key"
#   type        = string
# }

# variable "smtp_server" {
#   description = "SMTP server"
#   type        = string
# }

# variable "smtp_port" {
#   description = "SMTP port"
#   type        = number
# }

# variable "smtp_login" {
#   description = "SMTP user"
#   type        = string
# }

# variable "smtp_password" {
#   description = "SMTP password"
#   type        = string
# }

# variable "smtp_from_address" {
#   description = "SMTP from address"
#   type        = string
# }

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

# variable "ip_retention_period" {
#   description = "IP retention period"
#   type        = number
#   default     = 31556952
# }

# variable "session_retention_period" {
#   description = "Session retention period"
#   type        = number
#   default     = 31556952
# }