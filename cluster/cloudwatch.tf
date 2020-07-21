resource "aws_iam_policy" "eks-fluentd-cloudwatch" {
  count      = var.enable-cloudwatch ? 1 : 0
  name       = "${var.cluster-name}-fluentd-cloudwatch"
  path       = "/"

  policy     = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "eks-fluentd-cloudwatch" {
  count      = var.enable-cloudwatch ? 1 : 0
  policy_arn = aws_iam_policy.eks-fluentd-cloudwatch.*.arn[count.index]
  role       = aws_iam_role.kubernetes-node.name
}


resource "aws_cloudwatch_log_group" "kubernetes" {
  name              = "/aws/eks/${var.cluster-name}/apps"
  retention_in_days = var.cloudwatch-retention
}


resource "helm_release" "fluentd-cloudwatch" {
  count         = var.enable-cloudwatch ? 1 : 0
  name          = "fluentd-cloudwatch"
  recreate_pods = true
  repository = "https://kubernetes-charts-incubator.storage.googleapis.com"
  chart      = "fluentd-cloudwatch"
  version       = "0.12.1"
  values = [
    "${file("${path.module}/fluentd_values.yaml")}"
  ]

  set {
    name        = "rbac.create"
    value       = "true"
  }

  set {
    name        = "awsRegion"
    value       = var.cluster-region
  }

  set {
    name        = "logGroupName"
    value       = aws_cloudwatch_log_group.kubernetes.name
  }

  set {
    name     = "fullnameOverride"
    value    = "fluentd-cloudwatch"
  }

  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
    aws_cloudwatch_log_group.kubernetes,
  ]
}
