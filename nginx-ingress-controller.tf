
#SETUP KUBECTL
data "google_client_config" "provider" {}

provider "kubernetes" {
  host  = "https://${google_container_cluster.silvester_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.silvester_cluster.master_auth[0].cluster_ca_certificate,
  )
}

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