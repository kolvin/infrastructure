variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(any)
}

provider "aws" {
  region              = local.aws_region
  allowed_account_ids = ["${local.aws_account_id}"]
  default_tags {
    tags = merge(
      var.common_tags,
      local.additional_tags
    )
  }
}
