locals {
  # The Gateway's Service (Phase 5) uses these fixed NodePorts; kind forwards
  # the host ports to them so http://shoplite.localhost reaches the cluster.
  gateway_node_port_http  = 30080
  gateway_node_port_https = 30443
}

resource "kind_cluster" "this" {
  name           = var.cluster_name
  node_image     = var.node_image
  wait_for_ready = true
  # Standalone copy, gitignored; `make kubeconfig` merges into ~/.kube/config.
  kubeconfig_path = "${path.module}/kubeconfig"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      # The API server listens on localhost only, never on the LAN.
      api_server_address = "127.0.0.1"
    }

    node {
      role = "control-plane"

      # Only nodes labelled ingress-ready receive the forwarded host ports;
      # the Gateway's data plane is scheduled there.
      kubeadm_config_patches = [
        <<-EOT
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        EOT
      ]

      extra_port_mappings {
        container_port = local.gateway_node_port_http
        host_port      = var.http_port
        listen_address = "127.0.0.1"
        protocol       = "TCP"
      }
      extra_port_mappings {
        container_port = local.gateway_node_port_https
        host_port      = var.https_port
        listen_address = "127.0.0.1"
        protocol       = "TCP"
      }
    }

    dynamic "node" {
      for_each = var.worker_zones
      content {
        role = "worker"
        # Real clouds label nodes with their availability zone; doing the same
        # here makes topologySpreadConstraints and zone-aware PDBs testable.
        labels = {
          "topology.kubernetes.io/zone" = node.value
        }
      }
    }
  }
}
