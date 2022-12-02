[
  {
    "name": "mastodon-web",
    "image": "tootsuite/mastodon:${mastodon_version}",
    "command" : ["bundle", "exec", "rails", "s", "-p", "3000"],
    "essential": true,
    "mountPoints": [],
    "memory": ${web_memory},
    "volumesFrom": [],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs",
        "awslogs-group": "${log_group_name}"
      }
    },
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000,
        "protocol": "tcp"
      }
    ],
    "cpu": ${web_cpu},
    "environment": [
      {
        "name": "LOCAL_DOMAIN",
        "value": "${local_domain}"
      },
      {
        "name": "REDIS_HOST",
        "value": "${redis_host}"
      },
      {
        "name": "REDIS_PORT",
        "value": "${redis_port}"
      },
      {
        "name": "DB_HOST",
        "value": "${db_host}"
      },
      {
        "name": "DB_USER",
        "value": "${db_user}"
      },
      {
        "name": "DB_NAME",
        "value": "${db_name}"
      },
      {
        "name": "DB_PASS",
        "value": "${db_pass}"
      },
      {
        "name": "DB_PORT",
        "value": "${db_port}"
      },
      {
        "name": "ES_ENABLED",
        "value": "${es_enabled}"
      },
      {
        "name": "ES_HOST",
        "value": "${es_host}"
      },
      {
        "name": "ES_PORT",
        "value": "${es_port}"
      },
      {
        "name": "ES_USER",
        "value": "${es_user}"
      },
      {
        "name": "ES_PASS",
        "value": "${es_pass}"
      },
      {
        "name": "SECRET_KEY_BASE",
        "value": "${secret_key_base}"
      },
      {
        "name": "OTP_SECRET",
        "value": "${otp_secret}"
      },
      {
        "name": "VAPID_PRIVATE_KEY",
        "value": "${vapid_private_key}"
      },
      {
        "name": "VAPID_PUBLIC_KEY",
        "value": "${vapid_public_key}"
      },
      {
        "name": "SMTP_SERVER",
        "value": "${smtp_server}"
      },
      {
        "name": "SMTP_PORT",
        "value": "${smtp_port}"
      },
      {
        "name": "SMTP_LOGIN",
        "value": "${smtp_login}"
      },
      {
        "name": "SMTP_PASSWORD",
        "value": "${smtp_password}"
      },
      {
        "name": "SMTP_FROM_ADDRESS",
        "value": "${smtp_from_address}"
      },
      {
        "name": "S3_ENABLED",
        "value": "${s3_enabled}"
      },
      {
        "name": "S3_BUCKET",
        "value": "${s3_bucket}"
      },
      {
        "name": "S3_ALIAS_HOST",
        "value": "${s3_alias_host}"
      },
      {
        "name": "IP_RETENTION_PERIOD",
        "value": "${ip_retention_period}"
      },
      {
        "name": "SESSION_RETENTION_PERIOD",
        "value": "${session_retention_period}"
      }      
    ]
  }
]
