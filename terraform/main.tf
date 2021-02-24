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

resource "kubernetes_namespace" "namespace_ingress_nginx" {
    metadata {
      name = "ingress-nginx"
    }
}