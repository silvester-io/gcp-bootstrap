provider "kubernetes" {
  config_path = var.kubeconfig
}

# KUBE IP NAMESPACE
resource "kubernetes_namespace" "kubeip_namespace" {
  metadata {
    name = var.kubeip_kubernetes_namespace
  }
}

# CERT MANAGER NAMESPACE
resource "kubernetes_namespace" "certmanager_namespace" {
  metadata {
    name = var.certmanager_kubernetes_namespace
  }
}