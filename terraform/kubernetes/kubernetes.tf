# NAMESPACE
resource "kubernetes_namespace" "kubeip_namespace" {
  metadata {
    name = var.kubeip_kubernetes_namespace
  }
}