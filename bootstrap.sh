#!/bin/bash

################################################################################
# Multi-Environment DevOps Platform - Bootstrap Script
# 
# This script sets up the necessary AWS infrastructure for Terraform state
# management (S3 bucket and DynamoDB table)
#
# Usage: ./bootstrap.sh
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUCKET_NAME="multi-env-rayan"
TABLE_NAME="terraform-locks"
REGION="us-east-1"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Multi-Environment DevOps Platform - AWS Bootstrap        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print section headers
print_section() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}▶ $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print warning message
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check prerequisites
print_section "Checking Prerequisites"

if ! command_exists aws; then
    print_error "AWS CLI is not installed"
    echo "Please install AWS CLI: https://aws.amazon.com/cli/"
    exit 1
fi
print_success "AWS CLI found: $(aws --version)"

# Check AWS credentials
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    print_error "AWS credentials are not configured"
    echo "Please run: aws configure"
    exit 1
fi
print_success "AWS credentials configured"

# Display AWS account information
echo ""
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
echo -e "${BLUE}Account ID: ${NC}$ACCOUNT_ID"
echo -e "${BLUE}User ARN: ${NC}$USER_ARN"
echo ""

# Ask for confirmation
read -p "Continue with bootstrap for region '$REGION'? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Bootstrap cancelled"
    exit 0
fi

# Step 1: Create S3 Bucket
print_section "Creating S3 Bucket for Terraform State"

if aws s3 ls "s3://$BUCKET_NAME" 2>/dev/null; then
    print_warning "S3 bucket '$BUCKET_NAME' already exists"
else
    echo "Creating bucket '$BUCKET_NAME' in region '$REGION'..."
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || \
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" 2>/dev/null
    
    if aws s3 ls "s3://$BUCKET_NAME" > /dev/null; then
        print_success "S3 bucket created: $BUCKET_NAME"
    fi
fi

# Step 2: Enable S3 Versioning
print_section "Configuring S3 Bucket"

echo "Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
print_success "Versioning enabled"

echo "Enabling server-side encryption..."
aws s3api put-bucket-encryption \
    --bucket "$BUCKET_NAME" \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'
print_success "Encryption enabled"

echo "Blocking public access..."
aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
print_success "Public access blocked"

# Step 3: Create DynamoDB Table
print_section "Creating DynamoDB Table for State Locking"

if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" 2>/dev/null; then
    print_warning "DynamoDB table '$TABLE_NAME' already exists"
else
    echo "Creating DynamoDB table '$TABLE_NAME'..."
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region "$REGION"
    
    echo "Waiting for table to be created..."
    aws dynamodb wait table-exists \
        --table-name "$TABLE_NAME" \
        --region "$REGION"
    
    print_success "DynamoDB table created: $TABLE_NAME"
fi

# Step 4: Enable DynamoDB encryption
print_section "Configuring DynamoDB Table"

echo "Enabling point-in-time recovery..."
aws dynamodb update-continuous-backups \
    --table-name "$TABLE_NAME" \
    --point-in-time-recovery-specification PointInTimeRecoveryEnabled=true \
    --region "$REGION" 2>/dev/null || true
print_success "Point-in-time recovery configured"

# Step 5: Display Summary
print_section "Bootstrap Summary"

echo -e "${BLUE}S3 Bucket:${NC}"
echo "  Name: $BUCKET_NAME"
echo "  Region: $REGION"
echo "  Versioning: Enabled"
echo "  Encryption: Enabled"
echo "  Public Access: Blocked"
echo ""

echo -e "${BLUE}DynamoDB Table:${NC}"
echo "  Name: $TABLE_NAME"
echo "  Region: $REGION"
echo "  Read Capacity: 5"
echo "  Write Capacity: 5"
echo ""

# Step 6: Display next steps
print_section "Next Steps"

echo -e "1. Initialize Terraform for each environment:"
echo -e "   ${YELLOW}cd infra/envs/dev && terraform init${NC}"
echo -e "   ${YELLOW}cd infra/envs/staging && terraform init${NC}"
echo -e "   ${YELLOW}cd infra/envs/prod && terraform init${NC}"
echo ""

echo -e "2. Verify initialization:"
echo -e "   ${YELLOW}make all-validate${NC}"
echo ""

echo -e "3. Start with development environment:"
echo -e "   ${YELLOW}make dev-plan${NC}"
echo -e "   ${YELLOW}make dev-apply${NC}"
echo ""

print_success "AWS Bootstrap completed successfully!"
echo ""

# Display useful commands
print_section "Useful Commands Reference"

echo -e "${YELLOW}View S3 bucket contents:${NC}"
echo "  aws s3 ls s3://$BUCKET_NAME --recursive"
echo ""

echo -e "${YELLOW}View DynamoDB table:${NC}"
echo "  aws dynamodb describe-table --table-name $TABLE_NAME --region $REGION"
echo ""

echo -e "${YELLOW}View Terraform state:${NC}"
echo "  terraform state list"
echo "  terraform state show"
echo ""

echo -e "${YELLOW}Cleanup (removes S3 bucket and DynamoDB table):${NC}"
echo "  aws s3 rm s3://$BUCKET_NAME --recursive && aws s3api delete-bucket --bucket $BUCKET_NAME"
echo "  aws dynamodb delete-table --table-name $TABLE_NAME --region $REGION"
echo ""

echo -e "${BLUE}For more information, see:${NC}"
echo "  - README.md"
echo "  - DEPLOYMENT_GUIDE.md"
echo "  - REQUIREMENTS.md"
echo ""

exit 0
