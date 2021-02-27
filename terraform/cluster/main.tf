# CLUSTER NETWORK
module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 2.5"
  project_id   = var.project
  network_name = var.network

  subnets = [
    {
      subnet_name           = var.subnet_name
      subnet_ip             = "10.0.128.0/17"
      subnet_region         = var.cluster_region
      subnet_private_access = "true"
    },
  ]

  secondary_ranges = {
    "${var.subnet_name}" = [
      {
        range_name    = var.pods_ip_range_name
        ip_cidr_range = "192.168.128.0/18"
      },
      {
        range_name    =  var.services_ip_range_name
        ip_cidr_range = "192.168.192.0/18"
      },
    ]
  }
}


resource "google_compute_firewall" "http_node_port" {
  name    = "http-node-port"
  network = module.gcp_network.network_name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "https_node_port" {
  name    = "https-node-port"
  network = module.gcp_network.network_name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "ssh_node_port" {
  name = "ssh-node-port"
  network = module.gcp_network.network_name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
}

# CLUSTER
module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version    = "12.3.0"
  project_id = var.project
  name       = var.cluster_name
  regional   = false
  region     = var.cluster_region
  zones      = [var.cluster_location]

  network                 = module.gcp_network.network_name
  subnetwork              = module.gcp_network.subnets_names[0]
  ip_range_pods           = var.pods_ip_range_name
  ip_range_services       = var.services_ip_range_name
  create_service_account  = true
  enable_private_endpoint = false

  http_load_balancing        = false
  remove_default_node_pool   = true
  skip_provisioners          = true
  maintenance_start_time     = "04:00"
  network_policy             = false
  monitoring_service         = "none"
  logging_service            = "none"
  add_cluster_firewall_rules = false
  firewall_inbound_ports     = ["8443", "9443", "15017"]

  node_pools = [
    {
      name         = "ingress-pool"
      machine_type = "e2-micro"
      disk_size_gb = 10
      autoscaling  = false
      node_count   = 1
      image_type   = "COS_CONTAINERD"
      auto_upgrade = true
      preemptible  = true
    },
    {
      name               = "web-pool"
      machine_type       = "n2d-highmem-4"
      disk_size_gb       = 30
      autoscaling        = false
      initial_node_count = 1
      node_count         = 1
      image_type         = "COS_CONTAINERD"
      auto_upgrade       = true
      preemptible        = true
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/service.management",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  node_pools_taints = {
    all = []
    ingress-pool = [
      {
        key    = "dedicated"
        value  = "ingress"
        effect = "NO_SCHEDULE"
      }
    ]
  }

  node_pools_tags = {
    ingress-pool = [
      "ingress-pool"
    ]
    web-pool = [
      "web-pool"
    ]
  }

  master_authorized_networks = [
    {
      cidr_block   = module.gcp_network.subnets_ips[0]
      display_name = "VPC"
    },
    {
      display_name = "Anyone"
      cidr_block   = "0.0.0.0/0"
    },
  ]
}