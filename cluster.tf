provider "google" {
  project = var.project
}

# CLUSTER
resource "google_container_cluster" "silvester_cluster" {
  name = "silvester-cluster"
  location = var.cluster_location

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
  location = var.cluster_location

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
  location = var.cluster_location

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
