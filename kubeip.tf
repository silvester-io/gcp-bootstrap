# SERVICE ACCOUNT
resource "google_service_account" "kubeip_service_account" {
  account_id = "kubeip-service-account"
  display_name = "kubeIP"
}

# CLUSTER ROLE
resource "google_project_iam_custom_role" "kubeip_role" {
  role_id     = "kubeip"
  title       = "Kube IP Role"
  description = "required permissions to run KubeIP"
  stage = "GA"
  project = var.project
  permissions = ["compute.addresses.list", "compute.instances.addAccessConfig", "compute.instances.deleteAccessConfig", "compute.instances.get", "compute.instances.list", "compute.projects.get", "container.clusters.get", "container.clusters.list", "resourcemanager.projects.get", "compute.networks.useExternalIp", "compute.subnetworks.useExternalIp", "compute.addresses.use"]
}

# CLUSTER ROLE BINDING
resource "google_project_iam_binding" "kubeip_role_binding" {
  project = var.project
  role    = "projects/${var.project}/roles/kubeip"

  members = [
    "serviceAccount:kubeip-service-account@${var.project}.iam.gserviceaccount.com",
  ]
}