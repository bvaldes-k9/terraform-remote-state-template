############################################################################################################
# KMS Key
############################################################################################################

resource "aws_kms_key" "s3_backend" {
  description             = var.kms_key_describe
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_rotation_enable

  tags = var.tags
}

resource "aws_kms_alias" "s3_backend" {
  name          = "alias/${var.kms_key_alias}"
  target_key_id = aws_kms_key.s3_backend.key_id
}


############################################################################################################
# S3 Bucket Policy
############################################################################################################

data "aws_iam_policy_document" "tf_backend_force_ssl" {
  statement {
    sid = "SSLRequestsOnly"
    actions = [
      "s3:*",
    ]

    effect = "Deny"

    resources = [
      aws_s3_bucket.tf_backend.arn,
      "${aws_s3_bucket.tf_backend.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "tf_backend_force_ssl" {
  bucket = aws_s3_bucket.tf_backend.id
  policy = data.aws_iam_policy_document.tf_backend_force_ssl.json

  depends_on = [aws_s3_bucket_public_access_block.tf_backend]
}

resource "aws_s3_bucket_public_access_block" "tf_backend" {
  bucket                  = aws_s3_bucket.tf_backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################################################################################
# S3 bucket
############################################################################################################

resource "aws_s3_bucket" "tf_backend" {
  bucket        = var.s3_bucket_name
  force_destroy = var.s3_force_destroy

  tags = var.tags
}

resource "aws_s3_bucket_ownership_controls" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tf_backend" {
  depends_on = [aws_s3_bucket_ownership_controls.tf_backend]

  bucket = aws_s3_bucket.tf_backend.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.tf_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.s3_backend.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tf_backend" {
  bucket = aws_s3_bucket.tf_backend.id

  rule {
    id     = "archive"
    status = "Enabled"

    #block for object version expiration for better costs savings
    noncurrent_version_transition {
      noncurrent_days = var.transition_noncurrent_days
      storage_class   = var.storage_class
    }
    #block for object version expiration for better costs savings
    noncurrent_version_expiration {
      noncurrent_days = var.expiration_noncurrent_days
    }
  }
}


