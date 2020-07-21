resource "helm_release" "kubedashboard" {
  count      = var.enable-kubedashboard ? 1 : 0
  name       = "kubedashboard"
  namespace  = "kube-system"
  repository = "https://kubernetes-charts.storage.googleapis.com"
  chart      = "kubernetes-dashboard"
  version    = "1.10.1"

  set {
    name     = "fullnameOverride"
    value    = "kubernetes-dashboard"
  }

  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
  ]
}
