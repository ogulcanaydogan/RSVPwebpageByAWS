output "api_gateway_url" {
  description = "Invoke URL for the RSVP API Gateway"
  value       = "https://${aws_api_gateway_rest_api.rsvp_api.id}.execute-api.us-east-1.amazonaws.com/prod/rsvp"
}


output "s3_bucket_url" {
  value = "https://${data.aws_s3_bucket.rsvp.bucket}.s3.amazonaws.com/admin.html"
  description = "The URL to the admin.html page hosted in S3"
}

output "rsvp_js_url" {
  value = "https://${data.aws_s3_bucket.rsvp.bucket}.s3.amazonaws.com/rsvp.js"
  description = "The URL to the rsvp.js script hosted in S3"
}

output "lambda_function_name" {
  value = aws_lambda_function.rsvp_lambda.function_name
  description = "The name of the Lambda function"
}