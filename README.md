# ShopLite: infrastructure

Terraform that provisions the Kubernetes cluster. What runs *inside* the cluster (namespaces, apps, platform add-ons) is not here: it lives in [`shoplite-gitops`](https://github.com/shoplite-hazrat/shoplite-gitops) and is applied by Argo CD.

| Path | What |
|---|---|
| `terraform/kind/` | Local multi-node [kind](https://kind.sigs.k8s.io) cluster |
| `terraform/argocd/` | Bootstrap: installs Argo CD and the root app-of-apps that points at the gitops repo |
| `terraform/eks/` | (Phase 10) cloud cluster |

## Local cluster

Requires Docker, Terraform >= 1.14, kind and kubectl.

```bash
make up               # cluster + Argo CD bootstrap (~8 min first time)
kubectl get nodes -L topology.kubernetes.io/zone
make argocd-password  # initial admin password
make argocd-ui        # http://localhost:8090 (user: admin)
make down             # destroy
make check            # fmt + validate + tflint (same as CI)
```

### Bootstrap boundary

Terraform installs exactly two things into the cluster: **Argo CD** and **one root `Application`** (`argocd/root`) that tracks `shoplite-gitops/argocd/` on `main`. Everything else is declared in git and reconciled by Argo CD. To change what runs in the cluster, open a PR on the gitops repo; there is no `kubectl apply` and no Terraform involved.

| Node | Role | Labels |
|---|---|---|
| `shoplite-control-plane` | control plane, Gateway data plane | `ingress-ready=true`, host `127.0.0.1:8081` and `:8443` forwarded to NodePorts 30080/30443 |
| `shoplite-worker` | workloads | `topology.kubernetes.io/zone=zone-a` |
| `shoplite-worker2` | workloads | `topology.kubernetes.io/zone=zone-b` |

Design notes:
- **Zones on a laptop.** The worker zone labels make `topologySpreadConstraints` and zone-aware disruption budgets behave as they would on a cloud.
- **Pinned node image (by digest).** It matches the kind version bundled in the provider (v0.31.0), giving Kubernetes v1.35.0.
- **Localhost only.** The API server and forwarded ports bind to `127.0.0.1`, so they are not exposed on the LAN.
- **Ports 8081/8443, not 80/443.** Port 80 is in use on the dev machine and 8080 belongs to docker-compose. Override with `-var http_port=80 -var https_port=443`.
- **Local state.** Fine for a single-laptop cluster. Shared environments need a remote backend with locking.
