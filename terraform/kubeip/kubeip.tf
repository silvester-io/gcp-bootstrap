# SERVICE ACCOUNT
resource "google_service_account" "kubeip_service_account" {
  account_id = var.kubeip_google_serviceaccount_name
  display_name = "kubeIP"
  project = var.project
}

# CLUSTER ROLE V
resource "google_project_iam_custom_role" "kubeip_role" {
  role_id     = "kubeip"
  title       = "Kube IP Role"
  description = "required permissions to run KubeIP"
  stage = "GA"
  project = var.project
  permissions = ["compute.addresses.list", "compute.instances.addAccessConfig", "compute.instances.deleteAccessConfig", "compute.instances.get", "compute.instances.list", "compute.projects.get", "container.clusters.get", "container.clusters.list", "resourcemanager.projects.get", "compute.networks.useExternalIp", "compute.subnetworks.useExternalIp", "compute.addresses.use"]
}

# CLUSTER ROLE BINDING V
resource "google_project_iam_member" "kubeip_role_binding" {
  role    = "projects/${var.project}/roles/kubeip"
  project = var.project
  member = "serviceAccount:${var.kubeip_google_serviceaccount_name}@${var.project}.iam.gserviceaccount.com"
  depends_on = [ google_service_account.kubeip_service_account ]
}

# IAM Policy Binding V
resource "google_service_account_iam_binding" "kubeip_iam_policy_binding" {
  service_account_id = google_service_account.kubeip_service_account.name
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${var.kubeip_kubernetes_namespace}/${var.kubeip_kubernetes_serviceaccount_name}]",
  ]
}

# IP Addresses V
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