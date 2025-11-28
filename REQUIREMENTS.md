# Project Requirements

## 📋 متطلبات المشروع

### أداوات مطلوبة (Required Tools)

| الأداة | الإصدار الأدنى | الهدف |
|-------|-----------------|-------|
| Terraform | >= 1.0 | Infrastructure as Code |
| AWS CLI | >= 2.0 | تفاعل مع AWS |
| kubectl | >= 1.20 | إدارة Kubernetes |
| Docker | >= 20.0 | Build وPush الصور |
| aws-iam-authenticator | Latest | المصادقة مع EKS |

### مزودي خدمات AWS (AWS Providers)

في ملف `main.tf` لكل بيئة:

```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### موارد AWS (AWS Resources)

#### حساب AWS
- ✅ AWS Account فعال
- ✅ AWS Credentials مهيأة
- ✅ IAM Permissions كافية

#### الموارد المطلوبة مسبقاً:
1. **S3 Bucket** لتخزين الـ State:
   - اسم: `multi-env-rayan`
   - Versioning: مفعل
   - Encryption: مفعل

2. **DynamoDB Table** لـ State Locking:
   - اسم: `terraform-locks`
   - Primary Key: `LockID` (String)

### متطلبات اتصال الشبكة

```
┌─────────────────────────────────────┐
│      الجهاز المحلي (Local Machine) │
└──────────┬──────────────────────────┘
           │
    ┌──────▼──────────────────┐
    │   AWS API Endpoints      │
    │ - EKS API                │
    │ - EC2 API                │
    │ - CloudFormation         │
    └──────┬───────────────────┘
           │
    ┌──────▼──────────────────┐
    │   AWS Region: us-east-1 │
    │ - VPC                    │
    │ - EKS Cluster            │
    │ - ECR Repository         │
    └──────────────────────────┘
```

## 🔐 متطلبات الأمان (Security Requirements)

### AWS IAM Permissions

الحد الأدنى من الأذونات المطلوبة:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "eks:*",
        "ecr:*",
        "iam:*",
        "sts:AssumeRole",
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::multi-env-rayan",
        "arn:aws:s3:::multi-env-rayan/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/terraform-locks"
    }
  ]
}
```

### AWS Credentials Setup

```bash
# الطريقة 1: AWS Configure
aws configure
# يطلب:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json

# الطريقة 2: متغيرات البيئة
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# الطريقة 3: ملف credentials
cat ~/.aws/credentials
# [default]
# aws_access_key_id = YOUR_ACCESS_KEY
# aws_secret_access_key = YOUR_SECRET_KEY
```

## 📦 اعتماديات البرامج (Software Dependencies)

### Linux/macOS

```bash
# تحديث Package Manager
sudo apt-get update  # Debian/Ubuntu
brew update          # macOS

# تثبيت Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get install terraform

# تثبيت AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# تثبيت kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# تثبيت Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# تثبيت aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin/
```

### Windows (باستخدام Chocolatey)

```powershell
# تثبيت Terraform
choco install terraform

# تثبيت AWS CLI
choco install awscli

# تثبيت kubectl
choco install kubernetes-cli

# تثبيت Docker
choco install docker
```

## 🔍 التحقق من التثبيت (Verification)

```bash
# تحقق من الإصدارات
terraform version
aws --version
kubectl version --client
docker --version

# تحقق من الاتصال بـ AWS
aws sts get-caller-identity

# تحقق من S3 Bucket
aws s3 ls multi-env-rayan

# تحقق من DynamoDB
aws dynamodb describe-table --table-name terraform-locks
```

## 📊 متطلبات الموارد (Resource Requirements)

### الموارد على الجهاز المحلي

| المورد | الحد الأدنى | الموصى به |
|-------|-----------|----------|
| CPU | 2 cores | 4 cores |
| RAM | 4 GB | 8 GB |
| Disk Space | 20 GB | 50 GB |
| Internet | 1 Mbps | 5+ Mbps |

### موارد AWS المتوقعة

#### Development
- 1 VPC
- 2 Subnets (1 Public, 1 Private)
- 1 NAT Gateway
- 1 EKS Cluster
- 1 Node Group (1-2 nodes)
- 1 ECR Repository
- Estimated Cost: $100-150/month

#### Staging
- 1 VPC
- 2 Subnets (1 Public, 1 Private)
- 1 NAT Gateway
- 1 EKS Cluster
- 1 Node Group (2-4 nodes)
- 1 ECR Repository
- Estimated Cost: $250-350/month

#### Production
- 1 VPC
- 3 Subnets (1 Public, 2 Private) x 3 AZs
- 3 NAT Gateways
- 1 EKS Cluster
- 1 Node Group (3-6 nodes)
- 1 ECR Repository
- Estimated Cost: $500-700/month

## 🔄 CI/CD متطلبات (إذا كنت تستخدم GitHub Actions)

### GitHub Secrets المطلوبة

```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION (us-east-1)
TF_API_TOKEN (optional for Terraform Cloud)
```

### GitHub Actions Workflow

```yaml
name: Terraform Plan & Apply

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Terraform Init
        run: cd infra/envs/dev && terraform init
        
      - name: Terraform Plan
        run: cd infra/envs/dev && terraform plan
```

## ✅ قائمة التحقق قبل البدء (Pre-Deployment Checklist)

- [ ] تثبيت Terraform >= 1.0
- [ ] تثبيت AWS CLI >= 2.0
- [ ] تثبيت kubectl >= 1.20
- [ ] تثبيت Docker >= 20.0
- [ ] إعداد AWS Credentials
- [ ] إنشاء S3 Bucket للـ State
- [ ] إنشاء DynamoDB Table للـ Locks
- [ ] التحقق من IAM Permissions
- [ ] استنساخ المستودع
- [ ] قراءة README.md
- [ ] مراجعة DEPLOYMENT_GUIDE.md
- [ ] فهم بنية المجلدات

## 🚀 الخطوة التالية (Next Steps)

1. اقرأ [README.md](README.md)
2. اتبع [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
3. شغّل `make help` لرؤية جميع الأوامر المتاحة
4. جرّب `make dev-plan` أولاً في بيئة التطوير

---

**آخر تحديث**: نوفمبر 2025
**الإصدار**: 1.0
