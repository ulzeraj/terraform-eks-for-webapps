resource "helm_release" "cert-manager" {
  count            = var.enable-certmanager ? 1 : 0
  name             = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = "true"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "v0.15.0" 

  set {
    name           = "installCRDs"
    value          = "true"
  }

  set {
    name     = "fullnameOverride"
    value    = "cert-manager"
  }

  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
  ]
}

resource "null_resource" "cluster-issuer" {
  count            = var.enable-certmanager ? 1 : 0
  provisioner "local-exec" {
    command        = "kubectl apply -f ${path.module}/cluster_issuer.yaml"
    environment    = {
      KUBECONFIG   = "${path.module}/kubeconfig"
      AWS_PROFILE  = var.awsprofile
    }
  }
  depends_on = [
    aws_eks_cluster.kubernetes,
    aws_eks_node_group.main-node-group,
    helm_release.cert-manager,
    local_file.kubeconfig,
  ]
}
