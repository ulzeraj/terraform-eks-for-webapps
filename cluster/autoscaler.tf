resource "aws_iam_policy" "eks-autoscaler" {
  count       = var.enable-autoscaler ? 1 : 0
  name        = "${var.cluster-name}-autoscaler"
  description = "Allows to read and control autoscaling parameter for the node group."
  path        = "/"

  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "eks-autoscaler" {
  count       = var.enable-autoscaler ? 1 : 0
  policy_arn  = aws_iam_policy.eks-autoscaler.*.arn[count.index]
  role        = aws_iam_role.kubernetes-node.name
}


resource "helm_release" "cluster-autoscaler" {
  count       = var.enable-autoscaler ? 1 : 0
  name        = "cluster-autoscaler"
  namespace   = "kube-system"
  repository  = "https://kubernetes-charts.storage.googleapis.com"
  chart       = "cluster-autoscaler"
  version     = "7.0.0"
  set {
    name      = "cloudProvider"
    value     = "aws"
  }

  set {
    name      = "awsRegion"
    value     = var.cluster-region
  }

  set {
    name      = "autoDiscovery.enabled"
    value     = "true"
  }

  set {
    name      = "autoDiscovery.clusterName"
    value     = var.cluster-name
  }

  set {
    name      = "rbac.create"
    value     = "true"
  }

  set {
    name     = "fullnameOverride"
    value    = "cluster-autoscaler"
  }
  
  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group, 
  ]
}
