.DEFAULT_GOAL := help
TF := terraform -chdir=terraform/kind
CLUSTER := shoplite

.PHONY: help init plan up down kubeconfig check

help: ## Show available targets
	@grep -E '^[a-z-]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  %-11s %s\n", $$1, $$2}'

init: ## terraform init
	$(TF) init

plan: init ## Show what would change
	$(TF) plan

up: init ## Create the cluster and merge its kubeconfig
	$(TF) apply -auto-approve
	@$(MAKE) --no-print-directory kubeconfig

down: ## Destroy the cluster
	$(TF) destroy -auto-approve

kubeconfig: ## Merge the cluster into ~/.kube/config and switch to it
	kind export kubeconfig --name $(CLUSTER)
	kubectl cluster-info --context kind-$(CLUSTER)

check: ## Format, validate and lint (what CI runs)
	terraform fmt -check -recursive
	$(TF) init -backend=false -input=false >/dev/null
	$(TF) validate
	cd terraform/kind && tflint --init >/dev/null && tflint
