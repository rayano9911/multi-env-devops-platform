.PHONY: help init plan apply destroy fmt validate clean

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Multi-Environment DevOps Platform - Makefile$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Development Commands
dev-init: ## Initialize Terraform for Development
	@echo "$(BLUE)Initializing Development environment...$(NC)"
	@cd infra/envs/dev && terraform init

dev-plan: ## Plan changes for Development
	@echo "$(BLUE)Planning Development environment...$(NC)"
	@cd infra/envs/dev && terraform plan -out=tfplan

dev-apply: ## Apply changes to Development
	@echo "$(RED)Applying Development environment...$(NC)"
	@cd infra/envs/dev && terraform apply tfplan

dev-destroy: ## Destroy Development infrastructure
	@echo "$(RED)DESTROYING Development environment! Type 'yes' to confirm$(NC)"
	@cd infra/envs/dev && terraform destroy

dev-output: ## Show Development outputs
	@echo "$(BLUE)Development Outputs:$(NC)"
	@cd infra/envs/dev && terraform output

dev-refresh: ## Refresh Development state
	@cd infra/envs/dev && terraform refresh

# Staging Commands
staging-init: ## Initialize Terraform for Staging
	@echo "$(BLUE)Initializing Staging environment...$(NC)"
	@cd infra/envs/staging && terraform init

staging-plan: ## Plan changes for Staging
	@echo "$(BLUE)Planning Staging environment...$(NC)"
	@cd infra/envs/staging && terraform plan -out=tfplan

staging-apply: ## Apply changes to Staging
	@echo "$(RED)Applying Staging environment...$(NC)"
	@cd infra/envs/staging && terraform apply tfplan

staging-destroy: ## Destroy Staging infrastructure
	@echo "$(RED)DESTROYING Staging environment! Type 'yes' to confirm$(NC)"
	@cd infra/envs/staging && terraform destroy

staging-output: ## Show Staging outputs
	@echo "$(BLUE)Staging Outputs:$(NC)"
	@cd infra/envs/staging && terraform output

staging-refresh: ## Refresh Staging state
	@cd infra/envs/staging && terraform refresh

# Production Commands
prod-init: ## Initialize Terraform for Production
	@echo "$(BLUE)Initializing Production environment...$(NC)"
	@cd infra/envs/prod && terraform init

prod-plan: ## Plan changes for Production
	@echo "$(BLUE)Planning Production environment...$(NC)"
	@cd infra/envs/prod && terraform plan -out=tfplan

prod-apply: ## Apply changes to Production
	@echo "$(RED)APPLYING PRODUCTION! Type 'yes' to confirm$(NC)"
	@cd infra/envs/prod && terraform apply tfplan

prod-destroy: ## Destroy Production infrastructure
	@echo "$(RED)DESTROYING PRODUCTION! Type 'yes' to confirm$(NC)"
	@cd infra/envs/prod && terraform destroy

prod-output: ## Show Production outputs
	@echo "$(BLUE)Production Outputs:$(NC)"
	@cd infra/envs/prod && terraform output

prod-refresh: ## Refresh Production state
	@cd infra/envs/prod && terraform refresh

# All Environments Commands
all-init: dev-init staging-init prod-init ## Initialize all environments

all-plan: dev-plan staging-plan prod-plan ## Plan all environments

all-validate: ## Validate all environments
	@echo "$(BLUE)Validating all environments...$(NC)"
	@cd infra/envs/dev && terraform validate
	@cd infra/envs/staging && terraform validate
	@cd infra/envs/prod && terraform validate
	@echo "$(GREEN)✓ All environments are valid$(NC)"

all-fmt: ## Format all Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	@cd infra/modules/vpc && terraform fmt
	@cd infra/modules/eks && terraform fmt
	@cd infra/modules/ecr && terraform fmt
	@cd infra/envs/dev && terraform fmt
	@cd infra/envs/staging && terraform fmt
	@cd infra/envs/prod && terraform fmt
	@echo "$(GREEN)✓ All files formatted$(NC)"

# Utility Commands
fmt: ## Format current Terraform files
	@echo "$(BLUE)Formatting Terraform files...$(NC)"
	@terraform fmt -recursive
	@echo "$(GREEN)✓ Files formatted$(NC)"

validate: ## Validate current Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	@terraform validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

clean: ## Clean Terraform files and outputs
	@echo "$(BLUE)Cleaning up...$(NC)"
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "*.tfplan" -delete
	@find . -name "*-outputs.json" -delete
	@rm -f tfplan
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

version: ## Show Terraform version
	@terraform version

status: ## Show status of all environments
	@echo "$(BLUE)Environment Status:$(NC)"
	@echo ""
	@echo "$(GREEN)Development:$(NC)"
	@cd infra/envs/dev && terraform state list 2>/dev/null | wc -l
	@echo "$(GREEN)Staging:$(NC)"
	@cd infra/envs/staging && terraform state list 2>/dev/null | wc -l
	@echo "$(GREEN)Production:$(NC)"
	@cd infra/envs/prod && terraform state list 2>/dev/null | wc -l

# Kubernetes Commands
k8s-configure-dev: ## Configure kubectl for Development
	@echo "$(BLUE)Configuring kubectl for Development...$(NC)"
	@aws eks update-kubeconfig --name multi-env-devops-platform-dev-cluster --region us-east-1

k8s-configure-staging: ## Configure kubectl for Staging
	@echo "$(BLUE)Configuring kubectl for Staging...$(NC)"
	@aws eks update-kubeconfig --name multi-env-devops-platform-staging-cluster --region us-east-1

k8s-configure-prod: ## Configure kubectl for Production
	@echo "$(BLUE)Configuring kubectl for Production...$(NC)"
	@aws eks update-kubeconfig --name multi-env-devops-platform-prod-cluster --region us-east-1

k8s-nodes: ## Show Kubernetes nodes
	@echo "$(BLUE)Kubernetes Nodes:$(NC)"
	@kubectl get nodes -o wide

k8s-pods: ## Show all Kubernetes pods
	@echo "$(BLUE)Kubernetes Pods:$(NC)"
	@kubectl get pods --all-namespaces

k8s-services: ## Show Kubernetes services
	@echo "$(BLUE)Kubernetes Services:$(NC)"
	@kubectl get services --all-namespaces

# AWS Commands
aws-regions: ## List available AWS regions
	@aws ec2 describe-regions --query 'Regions[].RegionName' --output table

aws-account: ## Show AWS account information
	@aws sts get-caller-identity

ecr-login: ## Login to ECR
	@echo "$(BLUE)Logging in to ECR...$(NC)"
	@aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $$(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
	@echo "$(GREEN)✓ Logged in to ECR$(NC)"

# Documentation Commands
docs-help: ## Show documentation files
	@echo "$(BLUE)Documentation Files:$(NC)"
	@echo "  - README.md - Main project documentation"
	@echo "  - DEPLOYMENT_GUIDE.md - Step-by-step deployment instructions"
	@echo "  - ENVIRONMENT_CONFIG.md - Environment configuration guide"
	@echo "  - Makefile - This file with useful commands"

.DEFAULT_GOAL := help
