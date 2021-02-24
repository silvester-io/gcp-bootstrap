terraform {
  backend "gcs" {
    bucket  = "terraform-state-silvester"
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
    services_ip_range_name = ver.services_ip_range_name
}

resource "kubernetes_namespace" "namespace_ingress_nginx" {
    metadata {
      name = "ingress-nginx"
    }
}