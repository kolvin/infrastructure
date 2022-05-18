locals {
  account     = read_terragrunt_config(find_in_parent_folders("account.terragrunt.hcl"))
  environment = read_terragrunt_config(find_in_parent_folders("environment.terragrunt.hcl"))

  # Read config file
  config = jsondecode(file("${get_parent_terragrunt_dir()}/config.json"))
  
  # Extract values from folder namespacing
  # accounts/<account_ref>/region/<env>"
  path          = path_relative_to_include()
  path_split    = split("/", local.path)
  accounts      = local.path_split[0]
  account_ref   = local.path_split[1]
  aws_region    = local.path_split[2]
  env           = local.path_split[3]

  backend_filename = local.config.terragrunt.backend_filename

  tags = merge(
    local.account.locals.common_resource_tags,
    {
      Env      = local.env
      Location = "${local.config.base.git_url}/${path_relative_to_include()}"
    }
  )
}

terraform {
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
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_parent_terragrunt_dir()}/templates/aws_provider.tf.tpl")
}

generate "terragrunt_local_vars" {
  path      = "_locals.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    locals {
      terragrunt_dir        = "${get_terragrunt_dir()}"
      parent_terragrunt_dir = "${get_parent_terragrunt_dir()}"
      user_data_dir         = "${get_parent_terragrunt_dir()}/user_data"
      template_dir          = "${get_parent_terragrunt_dir()}/templates"
      backend_filename      = "${local.backend_filename}"
      env                   = "${local.env}"
      aws_account_id        = "${local.account.locals.aws_account_id}"
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
    bucket         = "terragrunt-state-${local.account_ref}-${local.env}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terragrunt-locks"
  }
  generate = {
    path      = local.backend_filename
    if_exists = "overwrite_terragrunt"
  }
}