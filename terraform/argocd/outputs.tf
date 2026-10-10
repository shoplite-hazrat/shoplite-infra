output "argocd_namespace" {
  description = "Namespace Argo CD runs in."
  value       = helm_release.argocd.namespace
}

output "argocd_version" {
  description = "Deployed Argo CD application version."
  value       = helm_release.argocd.metadata.app_version
}

output "admin_password_command" {
  description = "Prints the generated initial admin password."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "ui_command" {
  description = "Opens the Argo CD UI on http://localhost:8090 until the Gateway exists."
  value       = "kubectl -n argocd port-forward svc/argocd-server 8090:80"
}
