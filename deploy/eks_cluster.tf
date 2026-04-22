resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_public_access  = true
    endpoint_private_access = true

    subnet_ids = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id,
      aws_subnet.private_3.id
    ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "fargate"
  pod_execution_role_arn = aws_iam_role.fargate_execution_role.arn
  subnet_ids             = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]

  selector {
    namespace = "default"
  }
  selector {
    namespace = "kube-system"
  }
}

# OIDC Provider (Required for LB Controller)
data "tls_certificate" "eks_cluster_identity_oidc_issuer" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_openid_connect_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_identity_oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}
