# Multi-Environment DevOps Platform 🚀

A comprehensive Infrastructure as Code project showcasing DevOps best practices with multiple environments (Dev, Staging, Production) using Terraform, AWS EKS, ECR, and VPC.

## 📋 Project Overview

This project demonstrates a production-ready DevOps infrastructure with:

- **Multi-Environment Architecture**: Separate configurations for Dev, Staging, and Production
- **Infrastructure as Code**: Everything managed through Terraform
- **AWS Services**: VPC, EKS (Kubernetes), ECR (Container Registry)
- **Scalability**: Auto-scaling node groups with environment-specific configurations
- **Security**: Proper IAM roles, security groups, and network segmentation
- **State Management**: Remote state storage with S3 and DynamoDB locks

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   AWS Account                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VPC (Environment-Specific)         │  │
│  │                                                  │  │
│  │  ┌────────────────┐  ┌────────────────────────┐ │  │
│  │  │  Public Subnet │  │  Private Subnet (EKS) │ │  │
│  │  │                │  │                        │ │  │
│  │  │ NAT Gateway    │  │  EKS Nodes            │ │  │
│  │  │ IGW            │  │  (Worker Pods)        │ │  │
│  │  └────────────────┘  └────────────────────────┘ │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │           EKS Cluster (Kubernetes)             │   │
│  │  - API Server                                  │   │
│  │  - Control Plane (AWS Managed)                 │   │
│  │  - Node Groups (Auto-Scaling)                  │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │  ECR (Elastic Container Registry)              │   │
│  │  - Private Docker Image Repository             │   │
│  │  - Image Scanning & Lifecycle Policies         │   │
│  └────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
infra/
├── backend.tf                 # S3 backend configuration
├── modules/
│   ├── vpc/
│   │   ├── main.tf           # VPC, Subnets, NAT Gateway, Routes
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eks/
│   │   ├── main.tf           # EKS Cluster, Node Groups, IAM Roles
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── ecr/
│       ├── main.tf           # ECR Repository, Lifecycle Policies
│       ├── variables.tf
│       └── outputs.tf
│
└── envs/
    ├── dev/
    │   ├── main.tf           # Development environment configuration
    │   ├── variables.tf       # Dev-specific variables
    │   └── outputs.tf
    │
    ├── staging/
    │   ├── main.tf           # Staging environment configuration
    │   ├── variables.tf       # Staging-specific variables
    │   └── outputs.tf
    │
    └── prod/
        ├── main.tf           # Production environment configuration
        ├── variables.tf       # Production-specific variables
        └── outputs.tf
```

## 🔧 Environment Configuration

### Development Environment
- **VPC CIDR**: 10.0.0.0/16
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
- **Private Subnets**: 10.0.11.0/24, 10.0.12.0/24
- **Node Instances**: t3.small
- **Desired Nodes**: 1 | Min: 1 | Max: 2
- **Disk Size**: 30 GB

### Staging Environment
- **VPC CIDR**: 10.1.0.0/16
- **Public Subnets**: 10.1.1.0/24, 10.1.2.0/24
- **Private Subnets**: 10.1.11.0/24, 10.1.12.0/24
- **Node Instances**: t3.medium
- **Desired Nodes**: 2 | Min: 2 | Max: 4
- **Disk Size**: 50 GB

### Production Environment
- **VPC CIDR**: 10.2.0.0/16
- **Public Subnets**: 10.2.1.0/24, 10.2.2.0/24, 10.2.3.0/24 (3 AZs)
- **Private Subnets**: 10.2.11.0/24, 10.2.12.0/24, 10.2.13.0/24 (3 AZs)
- **Node Instances**: t3.large
- **Desired Nodes**: 3 | Min: 3 | Max: 6
- **Disk Size**: 100 GB

## 📋 Prerequisites

### Required Tools
- **Terraform**: >= 1.0
- **AWS CLI**: >= 2.0
- **kubectl**: >= 1.20 (for Kubernetes interaction)
- **aws-iam-authenticator**: For EKS authentication

### AWS Requirements
1. AWS Account with appropriate permissions
2. S3 bucket for Terraform state (`multi-env-rayan`)
3. DynamoDB table for state locking (`terraform-locks`)

### Setup S3 & DynamoDB for State Management

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket multi-env-rayan \
  --region us-east-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket multi-env-rayan \
  --versioning-configuration Status=Enabled

# Block public access
aws s3api put-public-access-block \
  --bucket multi-env-rayan \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table for locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

## 🚀 Quick Start

### 1. Initialize Terraform

```bash
# For Development
cd infra/envs/dev
terraform init

# For Staging
cd infra/envs/staging
terraform init

# For Production
cd infra/envs/prod
terraform init
```

### 2. Plan Deployment

```bash
# Development
cd infra/envs/dev
terraform plan -out=tfplan

# Staging
cd infra/envs/staging
terraform plan -out=tfplan

# Production
cd infra/envs/prod
terraform plan -out=tfplan
```

### 3. Apply Configuration

```bash
# Development
cd infra/envs/dev
terraform apply tfplan

# Staging
cd infra/envs/staging
terraform apply tfplan

# Production (requires approval)
cd infra/envs/prod
terraform apply tfplan
```

### 4. Configure kubectl

```bash
# After cluster is created
aws eks update-kubeconfig \
  --name multi-env-devops-platform-dev-cluster \
  --region us-east-1

# Test connection
kubectl get nodes
```

## 📊 Outputs

After applying Terraform, you'll get:

```terraform
# VPC Information
vpc_id              = "vpc-xxxxxxxxxxxx"
vpc_cidr            = "10.0.0.0/16"
public_subnet_ids   = ["subnet-xxx", "subnet-xxx"]
private_subnet_ids  = ["subnet-xxx", "subnet-xxx"]

# ECR Information
ecr_repository_url  = "xxxxxxxxxxxxx.dkr.ecr.us-east-1.amazonaws.com/multi-env-devops-platform-dev"
ecr_repository_name = "multi-env-devops-platform-dev"

# EKS Information
eks_cluster_id      = "multi-env-devops-platform-dev-cluster"
eks_cluster_endpoint = "https://xxxxxxxxxxxxxx.eks.us-east-1.amazonaws.com"
eks_node_group_id   = "multi-env-devops-platform-dev-node-group"
```

## 🔐 Security Best Practices

✅ **Implemented**:
- Private subnets for EKS nodes
- NAT Gateway for outbound traffic
- Security groups with least privilege
- EKS cluster encryption
- ECR image scanning on push
- Remote state encryption with S3
- DynamoDB state locking

⚠️ **Additional Recommendations**:
- Enable EKS audit logging (configured but verify CloudWatch logs)
- Use IRSA (IAM Roles for Service Accounts) for pod permissions
- Implement Pod Security Policies/Standards
- Set up VPC Flow Logs for network monitoring
- Use AWS KMS for encryption keys

## 💰 Cost Estimation

### Monthly Costs (Approximate)
- **Dev**: $100-150/month (t3.small)
- **Staging**: $250-350/month (t3.medium)
- **Prod**: $500-700/month (t3.large)
- **EKS Control Plane**: $73/month per cluster
- **ECR**: $0.10 per GB storage + transfer costs

**Total**: ~$1,000-1,300/month for all three environments

## 📝 Common Tasks

### Deploy Application to EKS

```bash
# 1. Build and push Docker image
docker build -t my-app:1.0 .
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URI
docker tag my-app:1.0 $ECR_URI/my-app:1.0
docker push $ECR_URI/my-app:1.0

# 2. Create Kubernetes deployment
kubectl create deployment my-app --image=$ECR_URI/my-app:1.0 -n default

# 3. Expose service
kubectl expose deployment my-app --type=LoadBalancer --port=80 --target-port=8080
```

### Scale Node Groups

```bash
# Modify desired size in variables.tf and apply
cd infra/envs/dev
terraform apply -var="desired_size=3"
```

### Destroy Infrastructure

⚠️ **Warning**: This will delete all resources!

```bash
cd infra/envs/dev
terraform destroy

# Or use auto-approve (be careful!)
terraform destroy -auto-approve
```

## 🐛 Troubleshooting

### EKS Cluster Connection Issues
```bash
# Check IAM user/role can access EKS
aws sts get-caller-identity

# Verify kubeconfig
kubectl config current-context

# Check cluster status
kubectl get nodes
```

### ECR Authentication Errors
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $ECR_URI
```

### Terraform State Issues
```bash
# Backup current state
terraform state pull > backup.tfstate

# Refresh state
terraform refresh

# Validate configuration
terraform validate
```

## 📚 Additional Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Best Practices](https://www.terraform.io/language/values/variables#best-practices)

## 🤝 Contributing

This is a portfolio project. Suggestions and improvements are welcome!

## 📄 License

Open source - Use freely for learning and reference

## 📞 Support

For issues or questions, refer to AWS documentation or open an issue in the repository.

---

**Last Updated**: November 2025
**Terraform Version**: >= 1.0
**AWS Region**: us-east-1
