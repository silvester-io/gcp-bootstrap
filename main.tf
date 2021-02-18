provider "google" {
  project = "silvester-304916"
}

# CLUSTER
resource "google_container_cluster" "silvester_cluster" {
  name = "silvester-cluster"
  location = "europe-west1-b" # MUST BE A SINGLE ZONE, OTHERWISE IT COUNTS AS A REGIONAL CLUSTER

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}


# INGRESS NODE POOL
resource "google_container_node_pool" "silvester_nodepool_ingress" {
  name     = "silvester-nodepool-ingress"
  cluster  = google_container_cluster.silvester_cluster.name
  initial_node_count = 1
  location = "europe-west1-b" 

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "e2-micro" 
    preemptible  = true 
    disk_size_gb = 10
    taint = [ {
      effect = "NO_SCHEDULE"
      key = "dedicated"
      value = "ingress"
    } ]
  }
}

# APPLICATION NODE POOL
resource "google_container_node_pool" "silvester_nodepool_apps" {
  name     = "silvester-nodepool-apps"
  cluster  = google_container_cluster.silvester_cluster.name
  initial_node_count = 1
  location = "europe-west1-b" 

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    machine_type = "n2d-highmem-4" 
    preemptible  = true 
  }
}

#SETUP KUBECTL
data "google_client_config" "provider" {}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${google_container_cluster.silvester_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.silvester_cluster.master_auth[0].cluster_ca_certificate,
  )
}

#INGRESS CONTROLLER
resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    name = "ingress-nginx"
  }
}