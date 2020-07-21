data "external" "thumbprint" {
  program            = ["${path.module}/oidc-thumbprint.sh", var.cluster-region]
}


resource "aws_iam_openid_connect_provider" "terraform-eks-cluster" {
  count              = var.enable-externaldns ? 1 : 0
  client_id_list     = ["sts.amazonaws.com"]
  thumbprint_list    = [data.external.thumbprint.result.thumbprint]
  url                = aws_eks_cluster.kubernetes.identity.0.oidc.0.issuer
}


resource "aws_iam_role" "eks-external-dns" {
  count              = var.enable-externaldns ? 1 : 0
  name               = "${var.cluster-name}-external-dns"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.terraform-eks-cluster.*.arn[count.index]}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${aws_iam_openid_connect_provider.terraform-eks-cluster.*.url[count.index]}:sub": "system:serviceaccount:external-dns:external-dns"
        }
      }
    }
  ]
}
POLICY
}


resource "aws_iam_policy" "eks-external-dns" {
  count              = var.enable-externaldns ? 1 : 0
  name               = "${var.cluster-name}-external-dns"
  path               = "/"
  policy             = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/${var.externaldns-zone-id}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "sts:AssumeRoleWithWebIdentity"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "eks-external-dns" {
  count              = var.enable-externaldns ? 1 : 0
  role               = aws_iam_role.eks-external-dns.*.name[count.index]
  policy_arn         = aws_iam_policy.eks-external-dns.*.arn[count.index]
}


resource "helm_release" "external-dns" {
  count              = var.enable-externaldns ? 1 : 0
  name               = "external-dns"
  namespace          = "external-dns"
  create_namespace   = "true"
  repository         = "https://kubernetes-charts.storage.googleapis.com"
  chart              = "external-dns"
  version            = "2.20.4"
  set {
    name             = "rbac.create"
    value            = "true"
  }

  set {
    name             = "provider"
    value            = "aws"
  }

  set {
    name             = "aws.region"
    value            = var.cluster-region
  }

  set {
    name             = "aws.zoneType"
    value            = "public"
  }
  
  set {
    name             = "txtOwnerId"
    value            = var.externaldns-zone-id
  }

  set {
    name             = "source"
    value            = "ingress"
  }

  set {
    name             = "rbac.serviceAccountAnnotations.eks\\.amazonaws\\.com/role-arn"
    value            = aws_iam_role.eks-external-dns.*.arn[count.index]
  }

  set {
    name             = "fullnameOverride"
    value            = "external-dns"
  }

  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
  ]
}
