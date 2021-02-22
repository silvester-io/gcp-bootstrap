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
  initial_node_count = 1

  workload_identity_config {
    identity_namespace = "${var.project}.svc.id.goog"
  }
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
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
    machine_type = "e2-micro" 
    preemptible  = false 
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
    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }
    disk_size_gb = 30
    machine_type = "n2d-highmem-4" 
    preemptible  = true 
  }
}

# HTTP TRAFFIC
resource "google_compute_firewall" "http_node_port" {
  name    = "http-node-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

# HTTPS TRAFFIC
resource "google_compute_firewall" "https_node_port" {
  name    = "https-node-port"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
