resource "aws_ecr_repository" "this" {
  name                 = "${var.project}-${var.env}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = "${var.project}-${var.env}-ecr"
    Environment = var.env
    Project     = var.project
  }
}

# Lifecycle policy to keep only last N images
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus       = "tagged"
          tagPrefixList   = ["v"]
          countType       = "imageCountMoreThan"
          countNumber     = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than 30 days"
        selection = {
          tagStatus         = "untagged"
          countType         = "sinceImagePushed"
          countUnit         = "days"
          countNumber       = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
