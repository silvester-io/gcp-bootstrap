terraform {
  backend "gcs" {
    bucket  = "silvester-terraform-state"
    prefix  = "terraform/state"
  }
}

provider "google" {
  project = var.project
}

module "cluster" {
    source = "./cluster"

    project = var.project
    network = var.network
    cluster_location = var.cluster_location
    cluster_region = var.cluster_region
    cluster_name = var.cluster_name
    subnet_name = var.subnet_name
    pods_ip_range_name = var.pods_ip_range_name
    services_ip_range_name = var.services_ip_range_name
}

module "cluster_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "12.3.0"
  project_id   = var.project
  location     = var.cluster_location
  cluster_name = var.cluster_name
}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.cluster_auth.host
  cluster_ca_certificate = module.cluster_auth.cluster_ca_certificate
  token                  = module.cluster_auth.token
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "namespace_argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_namespace" "namespace_certmanager" {
  metadata {
    name = "cert-manager"
  }   
}

module "kubeip" {
  source = "./kubeip"

  google_serviceaccount_name = var.kubeip_google_serviceaccount_name
  kubernetes_serviceaccount_name = var.kubeip_kubernetes_serviceaccount_name
  kubernetes_namespace = var.kubeip_kubernetes_namespace
  cluster_region = var.cluster_region
  cluster_name = var.cluster_name
  project = var.project
}