variable "project" {
    type = string
    default = "silvester-304916"
}

variable "cluster_name" {
    type = string
    default = "silvester-cluster"
}

variable "cluster_location" {
    type = string
    default = "europe-west1-b"
}

variable "cluster_region" {
    type = string
    default = "europe-west1"
}

variable "kubeip_google_serviceaccount_name" {
    type = string
    default = "kubeip-service-account"
}

variable "kubeip_kubernetes_serviceaccount_name" {
    type = string
    default = "kubeip-serviceaccount"
}

variable "kubeip_kubernetes_namespace" {
    type = string
    default = "kubeip"
}
