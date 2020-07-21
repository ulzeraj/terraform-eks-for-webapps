#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "kubernetes-node" {
  name = "${var.cluster-name}-kubernetes-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kubernetes-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.kubernetes-node.name
}

resource "aws_iam_role_policy_attachment" "kubernetes-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.kubernetes-node.name
}

resource "aws_iam_role_policy_attachment" "kubernetes-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.kubernetes-node.name
}

resource "aws_security_group" "kubernetes-nodes-ingress-workstation-ssh" {
  name        = "${var.cluster-name}-ssh-to-nodes"
  description = "SSH communication with worker nodes"
  vpc_id      = var.aws-vpc-id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster-name}-ssh-to-nodes"
  }
}

resource "aws_security_group_rule" "kubernetes-nodes-ingress-workstation-ssh" {
  cidr_blocks       = [var.firewall-allow-source]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.kubernetes-nodes-ingress-workstation-ssh.id
  to_port           = 22
  type              = "ingress"
}


resource "aws_eks_node_group" "main-node-group" {
  cluster_name    = aws_eks_cluster.kubernetes.name
  node_group_name = "${var.cluster-name}-main-node-group"
  node_role_arn   = aws_iam_role.kubernetes-node.arn
  subnet_ids      = var.private-subnet-ids
  instance_types  = var.node-types

  remote_access {
    ec2_ssh_key               = aws_key_pair.deployer.key_name
    source_security_group_ids = [ aws_security_group.kubernetes-nodes-ingress-workstation-ssh.id ]
  }

  scaling_config {
    desired_size = var.size-desired
    max_size     = var.size-max
    min_size     = var.size-min
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${var.cluster-name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.kubernetes-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.kubernetes-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.kubernetes-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

output "worker-nodes-role" {
  value = aws_iam_role.kubernetes-node
}
