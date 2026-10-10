terraform {
  required_version = ">= 1.14"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.3"
    }
  }
}

# A separate root module from terraform/kind on purpose: providers here need a
# running cluster, and configuring a provider from a resource created in the
# same apply is fragile. Create the cluster first, then bootstrap it.
provider "helm" {
  kubernetes = {
    config_path    = pathexpand(var.kubeconfig_path)
    config_context = var.kube_context
  }
}
