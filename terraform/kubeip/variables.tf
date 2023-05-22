variable "project" {
    type = string
    default = "silvester-306016"
}

variable "google_serviceaccount_name" {
    type = string
    default = "kubeip-service-account"
}

variable "kubernetes_serviceaccount_name" {
    type = string
    default = "kubeip-serviceaccount"
}

variable "kubernetes_namespace" {
    type = string
    default = "kube-system"
}

variable "cluster_region" {
    type = string
    default = "europe-west4"
}

variable "cluster_name" {
    type = string
    default = "silvester-cluster"
}