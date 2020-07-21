#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "kubernetes-cluster" {
  name = var.cluster-name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kubernetes-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.kubernetes-cluster.name
}

resource "aws_iam_role_policy_attachment" "kubernetes-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.kubernetes-cluster.name
}

resource "aws_security_group" "kubernetes-cluster" {
  name        = var.cluster-name
  description = "Cluster communication with worker nodes"
  vpc_id      = var.aws-vpc-id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.cluster-name
  }
}

resource "aws_security_group_rule" "kubernetes-cluster-ingress-workstation-https" {
  cidr_blocks       = [var.firewall-allow-source]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.kubernetes-cluster.id
  to_port           = 443
  type              = "ingress"
}


resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster-name}/cluster"
  retention_in_days = var.cloudwatch-retention
}


resource "aws_eks_cluster" "kubernetes" {
  name                      = var.cluster-name
  role_arn                  = aws_iam_role.kubernetes-cluster.arn
  enabled_cluster_log_types = ["api", "audit"]
  version                   = var.cluster-version

  vpc_config {
    security_group_ids = [aws_security_group.kubernetes-cluster.id]
    subnet_ids         = var.public-subnet-ids
  }

  provisioner "local-exec" {
    command  = "until curl -k ${aws_eks_cluster.kubernetes.endpoint}/healthz; do sleep 5; done"
  }

  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role_policy_attachment.kubernetes-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.kubernetes-cluster-AmazonEKSServicePolicy,
  ]
}
