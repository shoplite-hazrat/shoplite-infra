.DEFAULT_GOAL := help
CLUSTER := shoplite
MODULES := kind argocd
tf = terraform -chdir=terraform/$(1)

.PHONY: help up down cluster bootstrap kubeconfig argocd-password argocd-ui check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-16s %s\n", $$1, $$2}'

up: cluster bootstrap ## Create the cluster and bootstrap Argo CD

cluster: ## Create the kind cluster and merge its kubeconfig
	$(call tf,kind) init -input=false
	$(call tf,kind) apply -auto-approve
	@$(MAKE) --no-print-directory kubeconfig

bootstrap: ## Install Argo CD and the root app-of-apps
	$(call tf,argocd) init -input=false
	$(call tf,argocd) apply -auto-approve

down: ## Destroy the cluster (Argo CD and everything in it go with it)
	$(call tf,kind) destroy -auto-approve
	rm -f terraform/argocd/terraform.tfstate terraform/argocd/terraform.tfstate.backup

kubeconfig: ## Merge the cluster into ~/.kube/config and switch to it
	kind export kubeconfig --name $(CLUSTER)
	kubectl cluster-info --context kind-$(CLUSTER)

argocd-password: ## Print the initial Argo CD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

argocd-ui: ## Port-forward the Argo CD UI to http://localhost:8090
	kubectl -n argocd port-forward svc/argocd-server 8090:80

check: ## Format, validate and lint all modules (what CI runs)
	terraform fmt -check -recursive
	@for m in $(MODULES); do \
	  echo "== $$m"; \
	  terraform -chdir=terraform/$$m init -backend=false -input=false >/dev/null && \
	  terraform -chdir=terraform/$$m validate && \
	  (cd terraform/$$m && tflint --init >/dev/null && tflint) || exit 1; \
	done
