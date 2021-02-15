provider "google" {
  project = "silvester-304916"
}

resource "google_container_cluster" "default" {
  name               = "silvester-cluster"
  location           = "europe-west1-b" # MUST BE A SINGLE ZONE, OTHERWISE IT COUNTS AS A REGIONAL CLUSTER
  min_master_version = "version"
  node_locations = ["europe-west1-b"] # CAN BE MULTI ZONE

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "memory_optimized" {
  name     = "silvester-nodepool"
  cluster  = google_container_cluster.default.name
  version = "0.01"
  initial_node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 1
  }

  management {
    auto_repair = true
  }

  node_config {
    machine_type = "n2d-highmem-4" 
    preemptible  = true 
  }
}

