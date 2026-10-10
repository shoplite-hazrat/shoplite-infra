variable "cluster_name" {
  description = "Name of the kind cluster (kubectl context becomes kind-<name>)."
  type        = string
  default     = "shoplite"
}

variable "node_image" {
  description = "kindest/node image. Must be one published for the kind version the provider bundles (v0.31.0); pinned by digest."
  type        = string
  default     = "kindest/node:v1.35.0@sha256:452d707d4862f52530247495d180205e029056831160e22870e37e3f6c1ac31f"
}

variable "worker_zones" {
  description = "One worker node per entry, labelled with that zone, to practise zone-aware scheduling."
  type        = list(string)
  default     = ["zone-a", "zone-b"]

  validation {
    condition     = length(var.worker_zones) >= 1
    error_message = "At least one worker is required."
  }
}

# Not 80/443 by default: this machine already runs a web server on 80, and
# 8080 is taken by the docker-compose gateway. Set to 80/443 if they're free.
variable "http_port" {
  description = "Host port forwarded to the Gateway's HTTP NodePort."
  type        = number
  default     = 8081
}

variable "https_port" {
  description = "Host port forwarded to the Gateway's HTTPS NodePort."
  type        = number
  default     = 8443
}
