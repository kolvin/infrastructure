locals {
  account_config = read_terragrunt_config(find_in_parent_folders("account.terragrunt.hcl"))

  # Read config file
  config = jsondecode(file("${get_parent_terragrunt_dir()}/config.json"))
  
  # Extract values from folder namespacing
  # <account_alias>/<env>/<region>/<component>
  path          = path_relative_to_include()
  path_split    = split("/", local.path)
  account_alias = local.path_split[0]
  env           = local.path_split[1]
  aws_region    = local.path_split[2] == "global" ? "eu-west-1" : local.path_split[2]
  component     = local.path_split[3]
  

  backend_filename   = local.config.terragrunt.backend_filename
  source_modules_dir = "${get_parent_terragrunt_dir()}/modules"

  tags = merge(
    local.account_config.locals.common_resource_tags,
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
  path      = "_provider.tf"
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
      source_modules_dir    = "${get_parent_terragrunt_dir()}/modules"
      backend_filename      = "${local.backend_filename}"
      env                   = "${local.env}"
      aws_account_id        = "${local.account_config.locals.aws_account_id}"
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
    bucket         = "terragrunt-state-${local.account_config.locals.aws_account_id}"
    key            = "${join("/", compact([local.env, local.component, local.aws_region]))}/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terragrunt-locks-${local.account_config.locals.aws_account_id}"
  }
  generate = {
    path      = local.backend_filename
    if_exists = "overwrite_terragrunt"
  }
}