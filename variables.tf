############################################################################################################
# Terraform State and Provider
############################################################################################################

terraform {
#  backend "s3" {
#      bucket          = "insert-bucket-name-from-bucket-name-variable"
#      key             = "file-folder-name-on-s3/terraform.tfstate"
#      region          = "aws-region-for-s3"
#      dynamodb_table  = "dynamo-name"
#      encrypt         = true
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.3"
    }
  }
}

############################################################################################################
# Main
############################################################################################################

variable "tags" {
  description = "A mapping of tags to assign to resources."
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

variable "provider_region" {
  description = "region to create AWS resources"
  type        = string
  default     = "us-east-2"
}

############################################################################################################
# KMS VARIABLES
############################################################################################################

variable "kms_key_describe" {
  description = "Description of KMS key's use"
  type        = string
  default     = "The key used to encrypt the remote state bucket."
}

variable "kms_key_deletion_window" {
  description = "The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30."
  type        = number
  default     = 30
}

variable "kms_key_rotation_enable" {
  description = "Specifies whether key rotation is enabled. Defaults to false."
  type        = bool
  default     = true
}

variable "kms_key_alias" {
  description = "The display name of the alias."
  type        = string
  default     = "key-tf-state"
}

############################################################################################################
# S3 bucket
############################################################################################################

variable "s3_bucket_name" {
  description = "Gives S3 bucket name."
  type        = string
  default     = "s3-bucket-name"
}

variable "s3_force_destroy" {
  description = "A boolean confirms objects to be deleted from S3 buckets, there wont be an error in attempt to terraform destroy the buckets."
  type        = bool
  default     = false
}

variable "transition_noncurrent_days" {
  description = "Days before moving a version to long term storage glacier"
  type        = number
  default     = 7
}

variable "storage_class" {
  description = "type of storage you'd want to use"
  type        = string
  default     = "GLACIER"
}

variable "expiration_noncurrent_days" {
  description = "Specifies days noncurrent object versions expire."
  type        = number
  default     = 8
}

############################################################################################################
# DynamoDB Table
############################################################################################################

variable "dynamodb_table_name" {
  description = "name for dynamodb table"
  type        = string
  default     = "dynamo-name"
}

variable "dynamodb_table_billing_mode" {
  description = "billing approach for dynamodb table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "lock_key_id" {
  description = "LockID to prevent user from making chnages at same time to the state"
  type        = string
  default     = "LockID"
}

variable "dynamodb_deletion_protection_enabled" {
  description = "deletion protection"
  type        = bool
  default     = true
}

variable "dynamodb_server_side_encryption" {
  description = "Encryption at rest options. AWS DynamoDB tables are automatically encrypted at rest with an AWS-owned Customer Master Key if this argument isn't specified."
  type        = bool
  default     = true
}

