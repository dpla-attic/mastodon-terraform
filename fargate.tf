resource "aws_ecs_cluster" "fargate_cluster" {
  name = "mastodon-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "web_capacity_provider" {
  cluster_name       = aws_ecs_cluster.fargate_cluster.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

# resource "aws_iam_role" "ecs_tasks_execution_role" {
#   name               = "ecs-tasks-execution-role"
#   assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
# }

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

