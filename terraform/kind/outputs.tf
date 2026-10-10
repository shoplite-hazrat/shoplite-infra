output "cluster_name" {
  description = "Name of the kind cluster."
  value       = kind_cluster.this.name
}

output "kube_context" {
  description = "kubectl context name, once merged with `make kubeconfig`."
  value       = "kind-${kind_cluster.this.name}"
}

output "endpoint" {
  description = "Kubernetes API server URL."
  value       = kind_cluster.this.endpoint
}

output "kubeconfig_path" {
  description = "Standalone kubeconfig written by the provider (gitignored)."
  value       = kind_cluster.this.kubeconfig_path
}

# Consumed by the Phase 4 bootstrap (installs Argo CD into this cluster).
output "client_certificate" {
  description = "Admin client certificate (PEM) for providers that talk to the cluster."
  value       = kind_cluster.this.client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Admin client key (PEM)."
  value       = kind_cluster.this.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Cluster CA certificate (PEM)."
  value       = kind_cluster.this.cluster_ca_certificate
  sensitive   = true
}
