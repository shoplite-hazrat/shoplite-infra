variable "kubeconfig_path" {
  description = "Kubeconfig containing the target cluster's context."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "kubectl context of the cluster to bootstrap."
  type        = string
  default     = "kind-shoplite"
}

variable "argocd_chart_version" {
  description = "argo/argo-cd Helm chart version (10.10.x = Argo CD v3.5)."
  type        = string
  default     = "10.10.2"
}

variable "argocd_apps_chart_version" {
  description = "argo/argocd-apps Helm chart version, used to create the root Application."
  type        = string
  default     = "2.0.6"
}

variable "gitops_repo_url" {
  description = "Git repository Argo CD syncs from."
  type        = string
  default     = "https://github.com/shoplite-hazrat/shoplite-gitops.git"
}

variable "gitops_revision" {
  description = "Branch, tag or commit of the gitops repo to track."
  type        = string
  default     = "main"
}

variable "gitops_root_path" {
  description = "Directory in the gitops repo holding Argo CD's own objects (projects, ApplicationSets)."
  type        = string
  default     = "argocd"
}
