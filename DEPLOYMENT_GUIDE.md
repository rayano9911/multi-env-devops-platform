# Deployment Guide

## المتطلبات المسبقة - Prerequisites

### 1. أدوات مطلوبة

```bash
# تثبيت Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# تثبيت AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# تثبيت kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# تثبيت aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/
```

### 2. AWS Account Setup

```bash
# تكوين AWS Credentials
aws configure

# تحقق من الاتصال
aws sts get-caller-identity
```

### 3. إعداد S3 & DynamoDB

```bash
#!/bin/bash

# Create S3 bucket for Terraform state
BUCKET_NAME="multi-env-rayan"
REGION="us-east-1"

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION

echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Creating DynamoDB table for locks..."
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region $REGION

echo "✅ S3 and DynamoDB setup completed!"
```

## خطوات الـ Deployment

### المرحلة 1: التهيئة

#### أ) تهيئة Development

```bash
cd infra/envs/dev
terraform init

# التحقق من الكود
terraform fmt
terraform validate
```

#### ب) تهيئة Staging

```bash
cd infra/envs/staging
terraform init
terraform fmt
terraform validate
```

#### ج) تهيئة Production

```bash
cd infra/envs/prod
terraform init
terraform fmt
terraform validate
```

### المرحلة 2: التخطيط والمراجعة

#### أ) معاينة التغييرات - Development

```bash
cd infra/envs/dev
terraform plan -out=dev.tfplan

# عرض تفاصيل التخطيط
terraform show dev.tfplan
```

#### ب) معاينة التغييرات - Staging

```bash
cd infra/envs/staging
terraform plan -out=staging.tfplan
terraform show staging.tfplan
```

#### ج) معاينة التغييرات - Production

```bash
cd infra/envs/prod
terraform plan -out=prod.tfplan
terraform show prod.tfplan
```

### المرحلة 3: التطبيق

#### ⚠️ ملاحظة هامة:
يُنصح بنشر البيئات بهذا الترتيب:
1. **Dev** (الأولى للاختبار)
2. **Staging** (للتحقق قبل Production)
3. **Prod** (الإنتاج)

#### أ) نشر Development

```bash
cd infra/envs/dev
terraform apply dev.tfplan

# الانتظار حتى تكتمل (عادة 10-15 دقيقة)
# حفظ الـ Outputs
terraform output > dev-outputs.json
```

#### ب) نشر Staging (بعد التأكد من Dev)

```bash
cd infra/envs/staging
terraform apply staging.tfplan

# حفظ الـ Outputs
terraform output > staging-outputs.json
```

#### ج) نشر Production (بعد اختبار Staging)

```bash
cd infra/envs/prod
terraform apply prod.tfplan

# حفظ الـ Outputs
terraform output > prod-outputs.json
```

## تكوين kubectl

بعد إنشاء المجموعات بنجاح:

```bash
# Development
aws eks update-kubeconfig \
  --name multi-env-devops-platform-dev-cluster \
  --region us-east-1

# Staging
aws eks update-kubeconfig \
  --name multi-env-devops-platform-staging-cluster \
  --region us-east-1

# Production
aws eks update-kubeconfig \
  --name multi-env-devops-platform-prod-cluster \
  --region us-east-1

# التحقق من الاتصال
kubectl get nodes

# عرض جميع السياقات
kubectl config get-contexts
```

## التحقق من النشر

```bash
# Check cluster status
kubectl cluster-info

# List nodes
kubectl get nodes -o wide

# Check node resources
kubectl top nodes

# View cluster events
kubectl get events --all-namespaces

# Check EKS version
kubectl version --short
```

## إعداد Container Registry (ECR)

### الدخول إلى ECR

```bash
# Get login token
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com

# Verify login
docker ps  # Should work without errors
```

### بناء ودفع صورة Docker

```bash
# Get ECR repository URL
ECR_URI=$(aws ecr describe-repositories \
  --query 'repositories[?contains(repositoryName, `dev`)].repositoryUri' \
  --output text \
  --region us-east-1)

# Build image
docker build -t my-app:1.0 .

# Tag image
docker tag my-app:1.0 $ECR_URI/my-app:1.0

# Push to ECR
docker push $ECR_URI/my-app:1.0

# Verify
aws ecr describe-images \
  --repository-name multi-env-devops-platform-dev \
  --region us-east-1
```

## مثال: نشر تطبيق على EKS

### 1. إنشاء Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR_ECR_URI/my-app:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
```

### 2. تطبيق الـ Deployment

```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Verify deployment
kubectl get deployments
kubectl get pods
kubectl get services

# Get Load Balancer URL
kubectl get service my-app-service -o wide
```

## المراقبة والـ Logging

### CloudWatch Logs

```bash
# View EKS cluster logs
aws logs describe-log-groups --region us-east-1

# View specific log stream
aws logs tail /aws/eks/multi-env-devops-platform-dev-cluster/cluster --follow

# View application logs
kubectl logs deployment/my-app -f
```

### Metrics and Monitoring

```bash
# Install metrics-server (if not already installed)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View node metrics
kubectl top nodes

# View pod metrics
kubectl top pods
```

## تنظيف الموارد - Cleanup

### حذف التطبيق

```bash
# Remove deployment
kubectl delete deployment my-app

# Remove service
kubectl delete service my-app-service
```

### حذف البنية الأساسية

⚠️ **تحذير: هذا سيحذف جميع الموارد!**

```bash
# For Development
cd infra/envs/dev
terraform destroy -auto-approve

# For Staging
cd infra/envs/staging
terraform destroy -auto-approve

# For Production
cd infra/envs/prod
terraform destroy -auto-approve

# Clean up S3 state files (optional)
aws s3 rm s3://multi-env-rayan --recursive
```

## استكشاف الأخطاء

### مشاكل الاتصال بـ EKS

```bash
# Check current context
kubectl config current-context

# Check kubeconfig
cat ~/.kube/config

# Update kubeconfig
aws eks update-kubeconfig \
  --name multi-env-devops-platform-dev-cluster \
  --region us-east-1

# Verify IAM permissions
aws iam get-user
```

### مشاكل الوصول إلى ECR

```bash
# Check repository existence
aws ecr describe-repositories --region us-east-1

# Check image push permissions
aws ecr get-authorization-token --region us-east-1

# Re-login to ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  $(aws sts get-caller-identity --query Account --output text).dkr.ecr.us-east-1.amazonaws.com
```

### مشاكل Terraform

```bash
# Validate configuration
terraform validate

# Check state file
terraform show

# Refresh state
terraform refresh

# Plan with detailed output
terraform plan -lock=false

# Backup state
terraform state pull > backup.tfstate

# List resources
terraform state list
```

## التحديثات والصيانة

### تحديث إصدار Kubernetes

```bash
# Update cluster version (in variables.tf)
# e.g., default = "1.30"

cd infra/envs/dev
terraform plan
terraform apply
```

### توسيع Node Group

```bash
# Update desired_size in variables.tf
desired_size = 5

terraform apply
```

### تطبيق تصحيحات الأمان

```bash
# Check for outdated modules
terraform version

# Upgrade providers
terraform init -upgrade

# Test changes
terraform plan
terraform apply
```

---

**Document Version**: 1.0
**Last Updated**: November 2025
**Status**: Production Ready ✅
