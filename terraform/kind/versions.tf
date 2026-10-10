terraform {
  required_version = ">= 1.14"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.11.0"
    }
  }

  # Local state is fine for a cluster that lives on one laptop. A shared
  # environment (Phase 10) uses a remote backend with locking instead, e.g.
  # S3 with use_lockfile = true, so two people can't apply at once.
}
