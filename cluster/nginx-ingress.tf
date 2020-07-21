resource "helm_release" "nginx-ingress" {
  count      = var.enable-nginxingress ? 1 : 0
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  set {
    name     = "fullnameOverride"
    value    = "nginx-ingress"
  }

  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
  ]
}
