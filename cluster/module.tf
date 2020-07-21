variable "awscredentials" {}
variable "awsprofile" {}
variable "cluster-version" {}
variable "aws-vpc-id" {}
variable "public-subnet-ids" {}
variable "cluster-name" {}
variable "private-subnet-ids" {}
variable "firewall-allow-source" {}
variable "node-types" {}
variable "size-desired" {}
variable "size-min" {}
variable "size-max" {}
variable "cluster-region" {}
variable "enable-kubedashboard" {}
variable "enable-autoscaler" {}
variable "enable-cloudwatch" {}
variable "enable-externaldns" {}
variable "enable-certmanager" {}
variable "enable-nginxingress" {}
variable "externaldns-zone-id" {}
variable "externaldns-zone-name" {}
variable "cloudwatch-retention" {}


data "aws_eks_cluster_auth" "kubernetes" {
  name     = aws_eks_cluster.kubernetes.id
}


provider "kubernetes" {
  version                  = "~> 1.11"
  load_config_file         = "false"
  host                     = aws_eks_cluster.kubernetes.endpoint
  cluster_ca_certificate   = base64decode(aws_eks_cluster.kubernetes.certificate_authority.0.data)
  token                    = data.aws_eks_cluster_auth.kubernetes.token
}


provider "helm" {
  version                  = "~> 1.2"
  kubernetes {
    load_config_file       = "false"
    host                   = aws_eks_cluster.kubernetes.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.kubernetes.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.kubernetes.token
  }
}
