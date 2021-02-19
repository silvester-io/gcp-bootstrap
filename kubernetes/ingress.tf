
#SETUP KUBECTL
data "google_client_config" "provider" {}

provider "kubernetes" {
  config_path = var.kubeconfig_path
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

resource "kubernetes_config_map" "ingress_nginx_configmap" {
  metadata {
    name = "ingress-nginx-controller"
    namespace = var.ingress_namespace
    labels = {
      "app.kubernetes.io/name" = var.ingress_namespace
      "app.kubernetes.io/instance" = var.ingress_namespace
      "app.kubernetes.io/version" = "0.44.0"
      "app.kubernetes.io/component" = "controller"
    }
  }
  data = {
    
  }
}

resource "kubernetes_cluster_role" "ingress_nginx_cluster_role" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name" = var.ingress_namespace
      "app.kubernetes.io/instance" = var.ingress_namespace
      "app.kubernetes.io/version" = "0.44.0"
    }
  }

  rule {
    api_groups = [""]
    resources = ["configmaps", "endpoints", "nodes", "pods", "secrets"]
    verbs = ["list", "watch"]
  }

  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["get"]
  }

  rule {
    api_groups = [""]
    resources = ["services"]
    verbs = ["get", "list", "watch"]
  }
  
  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources = ["ingresses"]
    verbs = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources = ["events"]
    verbs = ["create", "patch"]
  }

  rule {
    api_groups = ["extensions", "networking.k8s.io"]
    resources = ["ingresses/status"]
    verbs = ["update"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources = ["ingressclasses"]
    verbs = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "ingress_nginx_cluster_role_binding" {
  metadata {
    name = "ingress-nginx"
    labels = {
      "app.kubernetes.io/name" = var.ingress_namespace
      "app.kubernetes.io/instance" = var.ingress_namespace
      "app.kubernetes.io/version" = "0.44.0"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "ingress-nginx"
  }
  subject {
      kind = "ServiceAccount"
      name = "ingress-nginx"
      namespace = var.ingress_namespace
  }     
}