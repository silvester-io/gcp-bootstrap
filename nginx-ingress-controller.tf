
#SETUP KUBECTL
data "google_client_config" "provider" {}

#INGRESS CONTROLLER
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = var.ingress_namespace
  }
}

resource "kubernetes_service_account" "ingress_nginx_service_account" {
    metadata {
        name = "ingress-nginx-service-account"
        namespace = var.ingress_namespace
        labels = {
            "app.kubernetes.io/name" = var.ingress_namespace
            "app.kubernetes.io/instance" =  var.ingress_namespace
            "app.kubernetes.io/version" = "0.44.0"
            "app.kubernetes.io/component" = "controller"
        }
    }
}