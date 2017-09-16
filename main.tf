data "template_file" "task" {
  template_file = "${path.module}/../${var.task_definition_path}"
}

resource "aws_ecs_task_definition" "main" {
  family                = "${uuid()}"
  container_definitions = "${data.template_file.task.rendered}"

  lifecycle {
    ignore_changes = [
      "family",
      "container_definitions",
    ]

    create_before_destroy = true
  }
}

data "aws_ecs_task_definition" "main" {
  task_definition = "${aws_ecs_task_definition.main.family}"

  depends_on = [
    "aws_ecs_task_definition.main",
  ]
}

resource "aws_ecs_service" "main" {
  name            = "${var.service_name}"
  cluster         = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.main.family}:${max("${aws_ecs_task_definition.main.revision}", "${data.aws_ecs_task_definition.main.revision}")}"
  iam_role        = "${aws_iam_role.ecs.arn}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name   = "${var.loadbalancer_container_name}"
    container_port   = "${var.loadbalancer_container_port}"
  }

  depends_on = [
    "aws_ecs_task_definition.main",
  ]

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      "task_definition",
    ]
  }
}

resource "aws_iam_role" "ecs" {
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs" {
  role = "${aws_iam_role.ecs.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets",
        "ec2:Describe*",
        "ec2:AuthorizeSecurityGroupIngress"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

module "autoscaling" {
  source           = "github.com/nbcuniversal/terraform-app-autoscaling"
  ecs_cluster_name = "${var.cluster_name}"
  ecs_service_arn  = "${aws_ecs_service.main.id}"
  ecs_service_name = "${aws_ecs_service.main.name}"
}
