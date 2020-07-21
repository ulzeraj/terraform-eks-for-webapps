output "cluster-auth" {
  value = data.aws_eks_cluster_auth.kubernetes
}


output "cluster-host" {
  value = aws_eks_cluster.kubernetes.endpoint
}


output "cluster-ca-certificate" {
  value = base64decode(aws_eks_cluster.kubernetes.certificate_authority.0.data)
}


output "cluster-token" {
  value = data.aws_eks_cluster_auth.kubernetes.token
}


output "cluster-oidc-issuer" {
  value = aws_eks_cluster.kubernetes.identity.0.oidc.0.issuer
}
