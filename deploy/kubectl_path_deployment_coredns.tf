data "aws_eks_addon_version" "latest_coredns" {
  addon_name         = "coredns"
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  addon_version               = data.aws_eks_addon_version.latest_coredns.version
  resolve_conflicts_on_update = "OVERWRITE"

  # This native property tells EKS that CoreDNS should schedule on Fargate!
  configuration_values = jsonencode({
    computeType = "Fargate"
  })

  depends_on = [aws_eks_fargate_profile.fargate]
}