resource "helm_release" "metrics-server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  set {
    name  = "containerPort"
    value = "4443"
  }

  # Fargate specific: Ensure the metridcs server doesn't try to use host networking
  set {
    name  = "hostNetwork.enabled"
    value = "false"
  }

  # Force helm to wait for fargate
  depends_on = [aws_eks_fargate_profile.fargate]
}
