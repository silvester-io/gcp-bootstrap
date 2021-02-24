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
}

resource "kubernetes_namespace" "namespace_ingress_nginx" {
  name = "ingress-nginx"
}