## create a role
resource "aws_iam_role" "lambda_role" {
name   = "Spacelift_Test_Lambda_Function_Role"
assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

## Add IAM Policy
resource "aws_iam_policy" "iam_policy_for_lambda" {

 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 path         = "/"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

## Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}


## Create a ZIP of Python Application
data "archive_file" "zip_the_nodejs_code" {
type        = "zip"
source_dir  = "${path.module}/nodejsapp/github-actions-with-lambda/"
output_path = "${path.module}/nodejsapp/github-actions-with-lambda/hello.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/nodejsapp/github-actions-with-lambda/hello.zip"
function_name                  = "WorkMotion_lambda_function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "nodejs12.x"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}
