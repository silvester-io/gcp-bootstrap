provider "kubernetes" {
  config_path = var.kubeconfig
}

# NAMESPACE
resource "kubernetes_namespace" "kubeip_namespace" {
  metadata {
    name = var.kubeip_kubernetes_namespace
  }
}