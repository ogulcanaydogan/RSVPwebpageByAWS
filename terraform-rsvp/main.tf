provider "aws" {
  region = "us-east-1"
}

# 1️⃣ REFERENCE EXISTING S3 BUCKET
data "aws_s3_bucket" "rsvp" {
  bucket = "rsvp.ogulcanaydogan.com"
}

# 2️⃣ DYNAMODB TABLE FOR RSVP RESPONSES
resource "aws_dynamodb_table" "rsvp_table" {
  name         = "RSVPResponses"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

# 3️⃣ ATTACH POLICY TO EXISTING IAM ROLE FOR LAMBDA
resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = "aa.LambdaRSVPRole"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 4️⃣ PACKAGE LAMBDA FUNCTION
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# 5️⃣ CREATE LAMBDA FUNCTION
resource "aws_lambda_function" "rsvp_lambda" {
  function_name = "rsvpHandler"
  role          = "arn:aws:iam::211125457564:role/aa.LambdaRSVPRole"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.rsvp_table.name
    }
  }
}

# 6️⃣ API GATEWAY SETUP
resource "aws_api_gateway_rest_api" "rsvp_api" {
  name        = "RSVP API"
  description = "API for wedding RSVP"
}

resource "aws_api_gateway_resource" "rsvp_resource" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_api.id
  parent_id   = aws_api_gateway_rest_api.rsvp_api.root_resource_id
  path_part   = "rsvp"
}

# 7️⃣ ENABLE CORS AND OPTIONS METHOD (FIX CORS ERRORS)
resource "aws_api_gateway_method" "rsvp_options" {
  rest_api_id   = aws_api_gateway_rest_api.rsvp_api.id
  resource_id   = aws_api_gateway_resource.rsvp_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rsvp_options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rsvp_api.id
  resource_id             = aws_api_gateway_resource.rsvp_resource.id
  http_method             = aws_api_gateway_method.rsvp_options.http_method
  type                    = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "rsvp_options_response" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_api.id
  resource_id = aws_api_gateway_resource.rsvp_resource.id
  http_method = aws_api_gateway_method.rsvp_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "rsvp_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rsvp_api.id
  resource_id = aws_api_gateway_resource.rsvp_resource.id
  http_method = aws_api_gateway_method.rsvp_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS, POST'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'"
  }

  depends_on = [aws_api_gateway_integration.rsvp_options_integration]  # ✅ Fix dependency issue
}

# 8️⃣ POST METHOD FOR RSVP SUBMISSION
resource "aws_api_gateway_method" "rsvp_post" {
  rest_api_id   = aws_api_gateway_rest_api.rsvp_api.id
  resource_id   = aws_api_gateway_resource.rsvp_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "rsvp_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rsvp_api.id
  resource_id             = aws_api_gateway_resource.rsvp_resource.id
  http_method             = aws_api_gateway_method.rsvp_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.rsvp_lambda.invoke_arn
}

# 9️⃣ API DEPLOYMENT
resource "aws_api_gateway_deployment" "rsvp_deployment" {
  depends_on  = [aws_api_gateway_integration.rsvp_lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.rsvp_api.id
}

resource "aws_api_gateway_stage" "rsvp_stage" {
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.rsvp_api.id
  deployment_id = aws_api_gateway_deployment.rsvp_deployment.id
}

# 🔟 LAMBDA PERMISSION FOR API GATEWAY
resource "aws_lambda_permission" "apigateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rsvp_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.rsvp_api.execution_arn}/*/*"
}

# 🔢 UPLOAD UPDATED HTML AND JS FILES TO S3
resource "aws_s3_bucket_object" "admin_html" {
  bucket = data.aws_s3_bucket.rsvp.bucket
  key    = "admin.html"  # Path of the file inside the bucket
  source = "path/to/admin.html"  # Local path to your updated admin.html
  acl    = "public-read"  # Set permissions as needed
}

resource "aws_s3_bucket_object" "rsvp_js" {
  bucket = data.aws_s3_bucket.rsvp.bucket
  key    = "rsvp.js"     # Path of the file inside the bucket
  source = "path/to/rsvp.js"    # Local path to your updated rsvp.js
  acl    = "public-read"       # Set permissions as needed
}
