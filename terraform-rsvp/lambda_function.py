import json
import boto3
import datetime
import os

# Initialize DynamoDB
dynamodb = boto3.resource("dynamodb")
table_name = os.getenv("DYNAMODB_TABLE", "RSVPResponses")  # Uses environment variable if set
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        print(f"Received event: {event}")  # Debugging: Log incoming event

        # Check if request body exists
        if "body" not in event or not event["body"]:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Request body is missing"})
            }

        # Parse JSON request body
        try:
            body = json.loads(event["body"])
        except json.JSONDecodeError:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Invalid JSON format"})
            }

        print(f"Parsed body: {body}")  # Debugging: Log parsed request body

        # Input validation
        if "name" not in body or "attending" not in body:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Name and attendance status are required!"})
            }

        # Prepare RSVP data
        item = {
            "id": str(int(datetime.datetime.now().timestamp() * 1000)),  # Unique timestamp ID
            "name": body["name"],
            "attending": body["attending"],
            "guests": int(body["guests"]) if "guests" in body and body["attending"] == "yes" else 0
        }

        print(f"Storing data in DynamoDB: {item}")  # Debugging: Log stored data

        # Store RSVP data in DynamoDB
        response = table.put_item(Item=item)

        print(f"DynamoDB response: {response}")  # Debugging: Log DynamoDB response

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "RSVP recorded successfully!"})
        }

    except Exception as e:
        print(f"Error saving RSVP: {str(e)}")  # Debugging: Log errors
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Error processing RSVP", "error": str(e)})
        }
