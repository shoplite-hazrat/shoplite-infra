# Bootstrap: the only things Terraform puts *inside* the cluster.
#  1. Argo CD itself
#  2. One "root" Application pointing at the gitops repo (app-of-apps)
# Everything else (projects, environments, services, platform add-ons) is
# declared in git and created by Argo CD from there.

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  values = [file("${path.module}/values/argocd.yaml")]

  wait    = true
  timeout = 600
}

resource "helm_release" "root_app" {
  name       = "argocd-root"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version

  # The Application CRD comes from the argo-cd chart.
  depends_on = [helm_release.argocd]

  values = [yamlencode({
    applications = {
      root = {
        namespace = "argocd"
        project   = "default"
        # Deleting the root app must not cascade-delete every environment.
        finalizers = []
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = var.gitops_root_path
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
          retry = {
            limit = 10
            backoff = {
              duration    = "10s"
              factor      = 2
              maxDuration = "3m"
            }
          }
        }
      }
    }
  })]
}
