output "api_gateway_url" {
  description = "Invoke URL for the RSVP API Gateway"
  value       = "https://${aws_api_gateway_rest_api.rsvp_api.id}.execute-api.us-east-1.amazonaws.com/prod/rsvp"
}