#CLUSTER
variable "project" {
    type = string
    default = "silvester-306016"
}

variable "network" {
    type = string
    default = "silvester-network-1"
}

variable "cluster_location" {
    type = string
    default = "europe-west1-b"
}

variable "cluster_region" {
    type = string
    default = "europe-west1"
}

variable "cluster_name" {
    type = string
    default = "silvester-cluster"
}

variable "subnet_name" {
    type = string
    default = "silvester-subnet-1"
}

variable "pods_ip_range_name" {
    type = string
    default = "ip-range-pods"
}

variable "services_ip_range_name" {
    type = string
    default = "ip-range-services"
}

#KUBE IP
variable "kubeip_google_serviceaccount_name" {
    type = string
    default = "kubeip-serviceaccount"
}

variable "kubeip_kubernetes_serviceaccount_name" {
    type = string
    default = "kubeip-serviceaccount"
}

variable "kubeip_kubernetes_namespace" {
    type = string
    default = "kube-system"
}