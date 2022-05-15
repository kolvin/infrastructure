locals {
  # Read config file
  config = jsondecode(file("${get_parent_terragrunt_dir()}/config.json"))
  
  # Set values from config file
  aws_account_name = local.config.cloud_accounts.aws.account_name
  aws_account_id   = local.config.cloud_accounts.aws.account_id
  aws_region       = local.config.cloud_accounts.aws.region
  
  # Extract values from folder namespacing
  # examples/<service>/envs/<env>"
  path          = path_relative_to_include()
  path_split    = split("/", local.path)
  examples      = local.path_split[0]
  service       = local.path_split[1]
  env           = local.path_split[3]

  terraform_source_dir = "${get_parent_terragrunt_dir("root")}//${local.examples}/${local.service}/terraform"

  backend_filename = local.config.terragrunt.backend_filename

  tags = merge(
    local.config.cloud_accounts.aws.common_resource_tags,
    {
      Env      = local.env
      Service  = local.service
      Location = "${local.config.base.git_url}/${path_relative_to_include()}"
    }
  )
}

terraform {
  source = local.terraform_source_dir

  extra_arguments "plan" {
    commands  = ["plan"]
    arguments = ["-out=${get_terragrunt_dir()}/tgplan.out"]
  }
  
  extra_arguments "apply" {
    commands  = ["apply"]
    arguments = ["${get_terragrunt_dir()}/tgplan.out"]
  }
}

# Generate an AWS provider block
generate "aws_provider" {
  path      = "_aws_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_parent_terragrunt_dir()}/templates/aws_provider.tftpl")
}

generate "terragrunt_local_vars" {
  path      = "_tg_locals.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    locals {
      terragrunt_dir        = "${get_terragrunt_dir()}"
      parent_terragrunt_dir = "${get_parent_terragrunt_dir()}"
      user_data_dir         = "${get_parent_terragrunt_dir()}/user_data"
      template_dir          = "${get_parent_terragrunt_dir()}/templates"
      backend_filename      = "${local.backend_filename}"
      service               = "${local.service}"
      env                   = "${local.env}"
      aws_account_id        = "${local.aws_account_id}"
      aws_region            = "${local.aws_region}"
    }
  EOF
}

# Configure root level variables that all resources can inherit.
inputs = merge(
  {
    common_tags = local.tags # Pass common tags to child resources
  }
)

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "terragrunt-state-${local.aws_account_name}-${local.env}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terragrunt-locks"
  }
  generate = {
    path      = local.backend_filename
    if_exists = "overwrite_terragrunt"
  }
}