# NAMESPACE
resource "kubernetes_namespace" "kubeip_namespace" {
  metadata {
    name = var.kubeip_kubernetes_namespace
  }
}

# SERVICE ACCOUNT
resource "google_service_account" "kubeip_service_account" {
  account_id = var.kubeip_google_serviceaccount_name
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
    "serviceAccount:${var.kubeip_google_serviceaccount_name}@${var.project}.iam.gserviceaccount.com",
  ]
}

# IAM Policy Binding
resource "google_project_iam_binding" "kubeip_iam_policy_binding" {
  project = var.project
  role    = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project}.svc.id.goog[${var.kubeip_kubernetes_namespace}/${var.kubeip_kubernetes_serviceaccount_name}]",
  ]
}