resource "aws_iam_role" "terragrunt" {
  name               = "TerragruntDeploy"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${local.aws_account_id}"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.terragrunt.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}