variable "project" {
    type = string
    default = "silvester-304916"
}

variable "cluster_location" {
    type = string
    default = "europe-west1-b"
}

variable "kubeip_google_serviceaccount_name" {
    type = string
    default = "kubeip-service-account"
}

variable "kubeip_kubernetes_serviceaccount_name" {
    type = string
    default = "kubeip-serviceaccount"
}

variable "kubeconfig" {
    type = string
}