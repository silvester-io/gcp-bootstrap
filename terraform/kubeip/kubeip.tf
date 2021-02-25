# GOOGLE - Service Account
resource "google_service_account" "kubeip_service_account" {
  account_id = var.google_serviceaccount_name
  display_name = "kubeIP"
  project = var.project
}

# GOOGLE - Cluster Role
resource "google_project_iam_custom_role" "kubeip_role" {
  role_id     = "kubeip_role"
  title       = "KubeIP Role"
  description = "required permissions to run KubeIP"
  stage = "GA"
  project = var.project
  permissions = ["compute.addresses.list", "compute.instances.addAccessConfig", "compute.instances.deleteAccessConfig", "compute.instances.get", "compute.instances.list", "compute.projects.get", "container.clusters.get", "container.clusters.list", "resourcemanager.projects.get", "compute.networks.useExternalIp", "compute.subnetworks.useExternalIp", "compute.addresses.use"]
}

# GOOGLE - Cluster Role Binding
resource "google_project_iam_member" "kubeip_role_binding" {
  role    = "projects/${var.project}/roles/kubeip_role"
  project = var.project
  member = "serviceAccount:${var.google_serviceaccount_name}@${var.project}.iam.gserviceaccount.com"
  depends_on = [ google_service_account.kubeip_service_account ]
}

# GOOGLE - IAM Policy Binding
resource "google_service_account_iam_binding" "kubeip_iam_policy_binding" {
  service_account_id = google_service_account.kubeip_service_account.name
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${var.kubernetes_namespace}/${var.kubernetes_serviceaccount_name}]",
  ]
}

# GOOGLE - IP Addresses 
resource "google_compute_address" "kubeip_address_1" {
  provider = google-beta
  name = "kubeip-ip-1"
  region = var.cluster_region
  project = var.project
  network_tier = "STANDARD"
  
  labels = { 
    "kubeip" = var.cluster_name
  }
}

# KUBERNETES - Config Map
resource "kubernetes_config_map" "kubeip_configmap" {
  metadata {
    name = "kubeip-config"
    namespace = var.kubernetes_namespace
    labels = {
      "app" = "kubeip"
    }
  }

  data = {
    "KUBEIP_LABELKEY" = "kubeip"
    "KUBEIP_LABELVALUE" = var.cluster_name
    "KUBEIP_NODEPOOL" = "ingress-pool"
    "KUBEIP_FORCEASSIGNMENT" = "true"
    "KUBEIP_ADDITIONALNODEPOOLS" = ""
    "KUBEIP_TICKER" = "5"
    "KUBEIP_ALLNODEPOOLSkey" = "false"
  }
}

# KUBERNETES - Service Account
resource "kubernetes_service_account" "kubeip" {
  metadata {
    name      = var.kubernetes_serviceaccount_name
    namespace = var.kubernetes_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = "${google_service_account.kubeip_service_account.email}"
    }
  }
  automount_service_account_token = true
}

# KUBERNETES - Cluster Role
resource "kubernetes_cluster_role" "kubeip" {
  metadata {
    name = "kubeip"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "patch"]
  }
}

# KUBERNETES - Cluster Role Binding
resource "kubernetes_cluster_role_binding" "kubeip" {
  metadata {
    name = "kubeip"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.kubeip.metadata.0.name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.kubeip.metadata.0.name
    namespace = var.kubernetes_namespace
  }
}

# KUBERNETES - Deployment
resource "kubernetes_deployment" "kubeip" {
  metadata {
    name      = "kubeip"
    namespace = var.kubernetes_namespace
    labels = {
      app = "kubeip"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "kubeip"
      }
    }

    template {
      metadata {
        labels = {
          app = "kubeip"
        }
      }

      spec {
        container {
          image = "doitintl/kubeip:latest"
          name  = "kubeip"

          env_from {
            config_map_ref {
              name = kubernetes_config_map.kubeip_configmap.metadata.0.name
            }
          }

          resources {
            limits {
              cpu    = "50"
              memory = "50Mi"
            }
            requests {
              cpu    = "50m"
              memory = "50Mi"
            }
          }
        }
        automount_service_account_token = true
        node_selector = {
          "cloud.google.com/gke-nodepool" = "web-pool"
        }
        restart_policy       = "Always"
        priority_class_name  = "system-node-critical"
        service_account_name = kubernetes_service_account.kubeip.metadata.0.name
      }
    }
  }

  timeouts {
    create = "3m"
    update = "3m"
    delete = "3m"
  }
}